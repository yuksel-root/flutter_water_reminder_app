import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_water_reminder_app/core/local_storage/local_storage_manager.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

class WaterLocalState {
  const WaterLocalState({
    required this.entries,
    this.goal,
    this.syncedEntryIds = const {},
    this.goalDirty = false,
  });

  final List<WaterEntry> entries;
  final WaterGoal? goal;
  final Set<String> syncedEntryIds;
  final bool goalDirty;
}

String newLocalWaterId() {
  final timestamp = DateTime.now().microsecondsSinceEpoch;
  final random = Random().nextInt(0x7fffffff);
  return 'local_${timestamp}_$random';
}

class WaterLocalStore {
  WaterLocalStore({LocalStorageManager? storage})
    : _storage = storage ?? LocalStorageManager.instance;

  static const String _stateKey = 'water_state_today';
  static const String _historyKey = 'water_local_history';
  static const int _historyLimit = 365;

  final LocalStorageManager _storage;
  Future<void> _queue = Future<void>.value();

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    _queue = _queue.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }

  Future<WaterLocalState> loadState() => _enqueue(_readState);

  Future<void> saveState(WaterLocalState state) =>
      _enqueue(() => _writeState(state));

  Future<List<WaterHistory>> loadHistory() => _enqueue(_readHistory);

  Future<void> saveHistory(List<WaterHistory> history) =>
      _enqueue(() => _writeHistory(history));

  Future<void> upsertHistory(WaterHistory history) {
    return _enqueue(() async {
      final historyList = await _readHistory();
      final index = historyList.indexWhere(
        (item) => item.dateKey == history.dateKey,
      );
      if (index == -1) {
        historyList.add(history);
      } else {
        historyList[index] = history;
      }
      await _writeHistory(historyList);
    });
  }

  Future<void> mergeHistory(List<WaterHistory> items) {
    return _enqueue(() async {
      final historyList = await _readHistory();
      final byDate = {for (final item in historyList) item.dateKey: item};
      final todayKey = _todayKey();

      for (final item in items) {
        if (item.dateKey == todayKey) {
          byDate.putIfAbsent(item.dateKey, () => item);
        } else {
          byDate[item.dateKey] = item;
        }
      }

      await _writeHistory(byDate.values.toList());
    });
  }

  Future<WaterLocalState> _readState() async {
    final raw = await _storage.getString(_stateKey);
    if (raw == null || raw.isEmpty) {
      return const WaterLocalState(entries: []);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const WaterLocalState(entries: []);
      }

      final entries = <WaterEntry>[];
      final rawEntries = decoded['entries'];
      if (rawEntries is List) {
        for (final item in rawEntries) {
          if (item is! Map) continue;
          try {
            entries.add(_entryFromJson(Map<String, dynamic>.from(item)));
          } catch (_) {
            continue;
          }
        }
      }

      final goal = _goalFromJson(decoded['goal']);
      final syncedEntryIds = <String>{};
      final rawSyncedIds = decoded['syncedEntryIds'];
      if (rawSyncedIds is List) {
        for (final item in rawSyncedIds) {
          if (item is String && item.isNotEmpty) {
            syncedEntryIds.add(item);
          }
        }
      }

      final goalDirty = decoded['goalDirty'] == true;
      final storedDate = decoded['date'];
      final todayKey = _todayKey();

      if (storedDate != todayKey) {
        final reset = WaterLocalState(
          entries: const [],
          goal: goal,
          goalDirty: goalDirty,
        );
        await _writeState(reset);
        return reset;
      }

      entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return WaterLocalState(
        entries: entries,
        goal: goal,
        syncedEntryIds: syncedEntryIds,
        goalDirty: goalDirty,
      );
    } catch (_) {
      return const WaterLocalState(entries: []);
    }
  }

  Future<void> _writeState(WaterLocalState state) async {
    final payload = <String, dynamic>{
      'date': _todayKey(),
      'entries': state.entries.map(_entryToJson).toList(),
      'goal': state.goal == null ? null : _goalToJson(state.goal!),
      'syncedEntryIds': state.syncedEntryIds.toList(),
      'goalDirty': state.goalDirty,
    };

    await _storage.setString(_stateKey, jsonEncode(payload));
  }

  Future<List<WaterHistory>> _readHistory() async {
    final raw = await _storage.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final history = <WaterHistory>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        try {
          history.add(WaterHistory.fromMap(Map<String, dynamic>.from(item)));
        } catch (_) {
          continue;
        }
      }

      history.sort((a, b) => b.date.compareTo(a.date));
      return history;
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeHistory(List<WaterHistory> history) async {
    final sorted = [...history]..sort((a, b) => b.date.compareTo(a.date));
    final limited = sorted.take(_historyLimit).toList();
    final payload = limited.map(_historyToJson).toList();
    await _storage.setString(_historyKey, jsonEncode(payload));
  }

  Map<String, dynamic> _entryToJson(WaterEntry entry) {
    return {
      'id': entry.id,
      'consumedMl': entry.consumedMl,
      'createdAt': entry.createdAt.toIso8601String(),
    };
  }

  WaterEntry _entryFromJson(Map<String, dynamic> json) {
    return WaterEntry(
      id: json['id'] as String?,
      consumedMl: (json['consumedMl'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    );
  }

  WaterGoal? _goalFromJson(dynamic value) {
    if (value is! Map) return null;

    try {
      final json = Map<String, dynamic>.from(value);
      return WaterGoal.fromMap(json, id: json['id'] as String?);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _goalToJson(WaterGoal goal) {
    return {
      'id': goal.id,
      'targetMl': goal.targetMl,
      'period': goal.period.name,
      'startDate': goal.startDate.toIso8601String(),
      'endDate': goal.endDate?.toIso8601String(),
      'isActive': goal.isActive,
      'createdAt': goal.createdAt.toIso8601String(),
      'updatedAt': goal.updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _historyToJson(WaterHistory history) {
    return {
      'date': history.date.toIso8601String(),
      'dailyConsumedMl': history.dailyConsumedMl,
      'dailyEntryCount': history.dailyEntryCount,
      'goalMl': history.goalMl,
      'createdAt': history.createdAt.toIso8601String(),
    };
  }

  String _todayKey() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
