import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_water_reminder_app/blocs/firestore_repository.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

class HistoryRepository extends FirestoreRepository {
  HistoryRepository({super.firestore, super.auth});

  CollectionReference<Map<String, dynamic>> get _history =>
      userCollection('waterHistory');

  Future<List<WaterHistory>> fetchHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError.value(
        endDate,
        'endDate',
        'End date cannot be before start date',
      );
    }

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));

    final snapshot = await _history
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((document) => WaterHistory.fromMap(document.data()))
        .toList();
  }
}
