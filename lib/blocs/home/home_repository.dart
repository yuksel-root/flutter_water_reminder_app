import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_water_reminder_app/blocs/firestore_repository.dart';
import 'package:flutter_water_reminder_app/core/local_storage/water_local_store.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

class HomeRepository extends FirestoreRepository {
  HomeRepository({super.firestore, super.auth, WaterLocalStore? localStore})
    : _localStore = localStore ?? WaterLocalStore();

  final WaterLocalStore _localStore;

  CollectionReference<Map<String, dynamic>> get _entries =>
      userCollection('waterEntries');

  CollectionReference<Map<String, dynamic>> get _goals =>
      userCollection('waterGoals');

  CollectionReference<Map<String, dynamic>> get _history =>
      userCollection('waterHistory');

  Future<WaterLocalState> loadLocalState() => _localStore.loadState();

  Future<void> saveLocalState(WaterLocalState state) =>
      _localStore.saveState(state);

  Future<List<WaterHistory>> loadLocalHistory() => _localStore.loadHistory();

  Future<void> saveLocalHistory(List<WaterHistory> history) =>
      _localStore.saveHistory(history);

  Future<void> upsertLocalHistory(WaterHistory history) =>
      _localStore.upsertHistory(history);

  Future<List<WaterEntry>> fetchTodayEntries({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final snapshot = await _entries
        .where('date', isEqualTo: _dateKey(target))
        .get();

    final entries = snapshot.docs
        .map((document) => WaterEntry.fromMap(document.data(), id: document.id))
        .toList();

    entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return entries;
  }

  Future<void> upsertEntry(WaterEntry entry) async {
    final id = entry.id;
    if (id == null) {
      throw ArgumentError.value(entry, 'entry', 'Entry id is required');
    }
    await _entries.doc(id).set(entry.toMap());
  }

  Future<WaterGoal?> fetchActiveGoal({DateTime? date}) async {
    final target = date ?? DateTime.now();
    final snapshot = await _goals.where('isActive', isEqualTo: true).get();

    final goals = snapshot.docs
        .map((document) => WaterGoal.fromMap(document.data(), id: document.id))
        .where(
          (goal) =>
              goal.period == WaterGoalPeriod.daily && goal.isActiveOn(target),
        )
        .toList();

    goals.sort((a, b) => b.startDate.compareTo(a.startDate));
    return goals.isEmpty ? null : goals.first;
  }

  Future<void> upsertGoal(WaterGoal goal) async {
    final id = goal.id;
    if (id == null) {
      throw ArgumentError.value(goal, 'goal', 'Goal id is required');
    }
    await _goals.doc(id).set(goal.toMap(), SetOptions(merge: true));
  }

  Future<void> saveHistorySummary(WaterHistory history) async {
    await _history.doc(history.dateKey).set(history.toMap());
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
