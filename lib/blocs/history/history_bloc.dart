import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_event.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_repository.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_state.dart';
import 'package:flutter_water_reminder_app/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._repository, this._bootstrap)
    : super(HistoryState.initial()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryRefreshed>(_onRefreshed);
    on<HistoryRangeChanged>(_onRangeChanged);
    on<HistoryRemoteUpdated>(_onRemoteUpdated);
  }

  final HistoryRepository _repository;
  final AppBootstrap _bootstrap;

  bool _syncing = false;
  bool _syncRequested = false;

  Future<void> _onStarted(
    HistoryStarted event,
    Emitter<HistoryState> emit,
  ) async {
    await _loadLocal(emit);
    unawaited(_syncRemote());
  }

  Future<void> _onRefreshed(
    HistoryRefreshed event,
    Emitter<HistoryState> emit,
  ) async {
    await _loadLocal(emit);
    unawaited(_syncRemote());
  }

  Future<void> _onRangeChanged(
    HistoryRangeChanged event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        status: HistoryStatus.ready,
        history: const [],
        errorMessage: '',
      ),
    );

    await _loadLocal(emit);
    unawaited(_syncRemote());
  }

  Future<void> _onRemoteUpdated(
    HistoryRemoteUpdated event,
    Emitter<HistoryState> emit,
  ) async {
    if (isClosed ||
        state.startDate != event.startDate ||
        state.endDate != event.endDate) {
      return;
    }

    emit(
      state.copyWith(
        status: HistoryStatus.ready,
        history: _mergeHistory(state.history, event.history),
        errorMessage: '',
      ),
    );

    try {
      await _repository.mergeLocalHistory(event.history);
    } catch (error, stackTrace) {
      debugPrint('History local merge failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _loadLocal(Emitter<HistoryState> emit) async {
    final startDate = state.startDate;
    final endDate = state.endDate;

    try {
      final local = await _repository.loadLocalHistory(
        startDate: startDate,
        endDate: endDate,
      );

      if (isClosed ||
          state.startDate != startDate ||
          state.endDate != endDate) {
        return;
      }

      emit(
        state.copyWith(
          status: HistoryStatus.ready,
          history: _sortedHistory(local),
          errorMessage: '',
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('History local load failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (isClosed ||
          state.startDate != startDate ||
          state.endDate != endDate) {
        return;
      }

      emit(
        state.copyWith(
          status: HistoryStatus.ready,
          history: const [],
          errorMessage: '',
        ),
      );
    }
  }

  Future<void> _syncRemote() async {
    if (isClosed) return;

    if (_syncing) {
      _syncRequested = true;
      return;
    }

    _syncing = true;
    try {
      do {
        _syncRequested = false;
        await _syncRemoteOnce();
      } while (_syncRequested && !isClosed);
    } finally {
      _syncing = false;
    }

    if (_syncRequested && !isClosed) {
      unawaited(_syncRemote());
    }
  }

  Future<void> _syncRemoteOnce() async {
    try {
      if (!_bootstrap.isReady) {
        await _bootstrap.retry();
      }

      if (isClosed || !_bootstrap.isReady || !_repository.canUseFirestore) {
        return;
      }

      final startDate = state.startDate;
      final endDate = state.endDate;
      final remote = await _repository
          .fetchHistory(startDate: startDate, endDate: endDate)
          .timeout(const Duration(seconds: 12));

      if (isClosed ||
          state.startDate != startDate ||
          state.endDate != endDate) {
        return;
      }

      add(
        HistoryRemoteUpdated(
          history: remote,
          startDate: startDate,
          endDate: endDate,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('History remote refresh failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  List<WaterHistory> _mergeHistory(
    List<WaterHistory> local,
    List<WaterHistory> remote,
  ) {
    final byDate = {for (final item in local) item.dateKey: item};
    final todayKey = _todayKey();

    for (final item in remote) {
      if (item.dateKey == todayKey) {
        byDate.putIfAbsent(item.dateKey, () => item);
      } else {
        byDate[item.dateKey] = item;
      }
    }

    return _sortedHistory(byDate.values.toList());
  }

  List<WaterHistory> _sortedHistory(List<WaterHistory> history) {
    final sorted = [...history]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  String _todayKey() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
