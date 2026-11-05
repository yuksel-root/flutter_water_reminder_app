import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_water_reminder_app/blocs/firestore_repository.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';

class HomeRepository extends FirestoreRepository {
  HomeRepository({super.firestore, super.auth});

  CollectionReference<Map<String, dynamic>> get _entries =>
      userCollection('waterEntries');

  CollectionReference<Map<String, dynamic>> get _goals =>
      userCollection('waterGoals');

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

  Future<WaterEntry> addEntry(WaterEntry entry) async {
    final reference = await _entries.add(entry.toMap());
    return entry.copyWith(id: reference.id);
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

  Future<WaterGoal> saveGoal(WaterGoal goal) async {
    if (goal.id == null) {
      final reference = await _goals.add(goal.toMap());
      return goal.copyWith(id: reference.id);
    }

    await _goals.doc(goal.id).set(goal.toMap(), SetOptions(merge: true));
    return goal;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
