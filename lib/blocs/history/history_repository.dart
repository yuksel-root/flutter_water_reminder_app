import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_water_reminder_app/blocs/firestore_repository.dart';
import 'package:flutter_water_reminder_app/core/local_storage/water_local_store.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

class HistoryRepository extends FirestoreRepository {
  HistoryRepository({super.firestore, super.auth, WaterLocalStore? localStore})
    : _localStore = localStore ?? WaterLocalStore();

  final WaterLocalStore _localStore;

  CollectionReference<Map<String, dynamic>> get _history =>
      userCollection('waterHistory');

  Future<List<WaterHistory>> loadLocalHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final history = await _localStore.loadHistory();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    return history.where((item) {
      final date = DateTime(item.date.year, item.date.month, item.date.day);
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  Future<void> mergeLocalHistory(List<WaterHistory> history) =>
      _localStore.mergeHistory(history);

  Future<List<WaterHistory>> fetchHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (end.isBefore(start)) {
      throw ArgumentError('End date must not be before start date');
    }

    final nextDay = end.add(const Duration(days: 1));
    final snapshot = await _history
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(nextDay))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((document) => WaterHistory.fromMap(document.data()))
        .toList();
  }
}
