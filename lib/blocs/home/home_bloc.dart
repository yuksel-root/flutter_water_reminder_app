import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_event.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_repository.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_state.dart';
import 'package:flutter_water_reminder_app/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_water_reminder_app/core/local_storage/water_local_store.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository, this._bootstrap) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeWaterAdded>(_onWaterAdded);
    on<HomeGoalUpdated>(_onGoalUpdated);
    on<HomeRemoteUpdated>(_onRemoteUpdated);
  }

  final HomeRepository _repository;
  final AppBootstrap _bootstrap;

  final Set<String> _syncedEntryIds = {};
  final Map<String, WaterHistory> _historyCache = {};

  Future<void> _localQueue = Future<void>.value();
  bool _goalDirty = false;
  int _goalRevision = 0;
  bool _refreshing = false;
  bool _backingUp = false;
  bool _backupRequested = false;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    final localState = await _loadLocalState();
    final localHistory = await _loadLocalHistory();

    if (isClosed) return;

    _syncedEntryIds
      ..clear()
      ..addAll(localState.syncedEntryIds);
    _goalDirty = localState.goalDirty;
    _historyCache
      ..clear()
      ..addEntries(localHistory.map((item) => MapEntry(item.dateKey, item)));

    emit(
      state.copyWith(
        status: HomeStatus.ready,
        entries: _sortedEntries(localState.entries),
        activeGoal: localState.goal,
        errorMessage: '',
      ),
    );

    _scheduleLocalPersist();
    unawaited(_syncRemoteAndBackup());
  }

  void _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) {
    unawaited(_syncRemoteAndBackup());
  }

  void _onWaterAdded(HomeWaterAdded event, Emitter<HomeState> emit) {
    if (event.amountMl <= 0) return;

    final entry = WaterEntry(
      id: newLocalWaterId(),
      consumedMl: event.amountMl,
      createdAt: DateTime.now(),
    );
    final entries = _sortedEntries([...state.entries, entry]);

    emit(
      state.copyWith(
        status: HomeStatus.ready,
        entries: entries,
        errorMessage: '',
      ),
    );

    _scheduleLocalPersist();
    unawaited(_backupCurrent());
  }

  void _onGoalUpdated(HomeGoalUpdated event, Emitter<HomeState> emit) {
    if (event.targetMl <= 0) return;

    final now = DateTime.now();
    final current = state.activeGoal;
    final goal = current == null
        ? WaterGoal(
            id: newLocalWaterId(),
            targetMl: event.targetMl,
            period: WaterGoalPeriod.daily,
            startDate: now,
            createdAt: now,
          )
        : current.copyWith(targetMl: event.targetMl, updatedAt: now);

    _goalDirty = true;
    _goalRevision++;

    emit(
      state.copyWith(
        status: HomeStatus.ready,
        activeGoal: goal,
        errorMessage: '',
      ),
    );

    _scheduleLocalPersist();
    unawaited(_backupCurrent());
  }

  void _onRemoteUpdated(HomeRemoteUpdated event, Emitter<HomeState> emit) {
    if (isClosed) return;

    final mergedEntries = _mergeEntries(state.entries, event.entries);

    if (!_goalDirty && state.activeGoal != null && event.activeGoal == null) {
      _goalDirty = true;
    }

    final activeGoal = _resolveGoal(state.activeGoal, event.activeGoal);

    _syncedEntryIds.addAll(
      event.entries.map((entry) => entry.id).whereType<String>(),
    );

    emit(
      state.copyWith(
        status: HomeStatus.ready,
        entries: mergedEntries,
        activeGoal: activeGoal,
        errorMessage: '',
      ),
    );

    _scheduleLocalPersist();
    unawaited(_backupCurrent());
  }

  Future<void> _syncRemoteAndBackup() async {
    if (!_bootstrap.isReady) {
      await _bootstrap.retry();
    }

    if (isClosed || !_bootstrap.isReady || !_repository.canUseFirestore) {
      return;
    }

    await _refreshRemote();

    if (isClosed) return;
    await _backupCurrent();
  }

  Future<void> _refreshRemote() async {
    if (_refreshing || isClosed || !_repository.canUseFirestore) return;

    _refreshing = true;
    try {
      final remoteEntries = await _repository.fetchTodayEntries().timeout(
        const Duration(seconds: 12),
      );
      final remoteGoal = await _repository.fetchActiveGoal().timeout(
        const Duration(seconds: 12),
      );

      if (isClosed) return;

      add(HomeRemoteUpdated(entries: remoteEntries, activeGoal: remoteGoal));
    } catch (error, stackTrace) {
      debugPrint('Home remote refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _backupCurrent() async {
    if (_backingUp) {
      _backupRequested = true;
      return;
    }

    _backingUp = true;
    try {
      do {
        _backupRequested = false;
        await _localQueue;
        if (isClosed) return;
        await _runBackup();
      } while (_backupRequested && !isClosed);
    } finally {
      _backingUp = false;
    }

    if (_backupRequested && !isClosed) {
      unawaited(_backupCurrent());
    }
  }

  Future<void> _runBackup() async {
    if (isClosed || !_repository.canUseFirestore) return;

    final pendingEntries = state.entries
        .where(
          (entry) => entry.id != null && !_syncedEntryIds.contains(entry.id),
        )
        .toList();
    final goal = state.activeGoal;
    final goalToSync = _goalDirty ? goal : null;
    final goalRevision = _goalRevision;
    final history = _buildTodayHistory(state.entries, state.goalMl);
    final uploadedIds = <String>[];

    try {
      for (final entry in pendingEntries) {
        await _repository
            .upsertEntry(entry)
            .timeout(const Duration(seconds: 10));
        uploadedIds.add(entry.id!);
      }

      if (goalToSync != null) {
        await _repository
            .upsertGoal(goalToSync)
            .timeout(const Duration(seconds: 10));
      }

      await _repository
          .saveHistorySummary(history)
          .timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      debugPrint('Home backup failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (uploadedIds.isNotEmpty) {
        _syncedEntryIds.addAll(uploadedIds);
        _scheduleLocalPersist();
      }
      return;
    }

    if (isClosed) return;

    _syncedEntryIds.addAll(uploadedIds);
    if (goalToSync != null && goalRevision == _goalRevision) {
      _goalDirty = false;
    }

    _scheduleLocalPersist();
  }

  void _scheduleLocalPersist() {
    final localState = WaterLocalState(
      entries: List<WaterEntry>.unmodifiable(state.entries),
      goal: state.activeGoal,
      syncedEntryIds: Set<String>.unmodifiable(_syncedEntryIds),
      goalDirty: _goalDirty,
    );
    final history = _buildTodayHistory(state.entries, state.goalMl);
    _historyCache[history.dateKey] = history;

    _localQueue = _localQueue.then((_) async {
      try {
        await _repository.saveLocalState(localState);
        await _repository.upsertLocalHistory(history);
      } catch (error, stackTrace) {
        debugPrint('Home local persistence failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
  }

  Future<WaterLocalState> _loadLocalState() async {
    try {
      return await _repository.loadLocalState();
    } catch (error, stackTrace) {
      debugPrint('Home local state load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const WaterLocalState(entries: []);
    }
  }

  Future<List<WaterHistory>> _loadLocalHistory() async {
    try {
      return await _repository.loadLocalHistory();
    } catch (error, stackTrace) {
      debugPrint('Home local history load failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const [];
    }
  }

  List<WaterEntry> _mergeEntries(
    List<WaterEntry> current,
    List<WaterEntry> remote,
  ) {
    final byId = <String, WaterEntry>{};
    final withoutId = <WaterEntry>[];

    for (final entry in current) {
      final id = entry.id;
      if (id == null) {
        withoutId.add(entry);
      } else {
        byId[id] = entry;
      }
    }

    for (final entry in remote) {
      final id = entry.id;
      if (id == null) {
        withoutId.add(entry);
      } else {
        byId.putIfAbsent(id, () => entry);
      }
    }

    return _sortedEntries([...byId.values, ...withoutId]);
  }

  WaterGoal? _resolveGoal(WaterGoal? local, WaterGoal? remote) {
    if (_goalDirty) return local;
    return remote ?? local;
  }

  WaterHistory _buildTodayHistory(List<WaterEntry> entries, int goalMl) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    final dateKey = _dateKey(date);
    final consumedMl = entries.fold<int>(
      0,
      (total, entry) => total + entry.consumedMl,
    );

    return WaterHistory(
      date: date,
      dailyConsumedMl: consumedMl,
      dailyEntryCount: entries.length,
      goalMl: goalMl,
      createdAt: _historyCache[dateKey]?.createdAt ?? now,
    );
  }

  List<WaterEntry> _sortedEntries(List<WaterEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
