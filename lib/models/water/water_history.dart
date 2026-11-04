import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WaterHistory extends Equatable {
  const WaterHistory({
    required this.date,
    required this.dailyConsumedMl,
    required this.dailyEntryCount,
    required this.goalMl,
    required this.createdAt,
  });

  final DateTime date;
  final int dailyConsumedMl;
  final int dailyEntryCount;
  final int goalMl;
  final DateTime createdAt;

  String get dateKey {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  factory WaterHistory.fromMap(Map<String, dynamic> map) {
    return WaterHistory(
      date: _dateTimeFrom(map['date']),
      dailyConsumedMl: (map['dailyConsumedMl'] as num).toInt(),
      dailyEntryCount: (map['dailyEntryCount'] as num).toInt(),
      goalMl: (map['goalMl'] as num).toInt(),
      createdAt: _dateTimeFrom(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'dateKey': dateKey,
      'dailyConsumedMl': dailyConsumedMl,
      'dailyEntryCount': dailyEntryCount,
      'goalMl': goalMl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  WaterHistory copyWith({
    DateTime? date,
    int? dailyConsumedMl,
    int? dailyEntryCount,
    int? goalMl,
    DateTime? createdAt,
  }) {
    return WaterHistory(
      date: date ?? this.date,
      dailyConsumedMl: dailyConsumedMl ?? this.dailyConsumedMl,
      dailyEntryCount: dailyEntryCount ?? this.dailyEntryCount,
      goalMl: goalMl ?? this.goalMl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _dateTimeFrom(dynamic value) {
    if (value is Timestamp) return value.toDate().toLocal();
    if (value is DateTime) return value.toLocal();
    if (value is String) return DateTime.parse(value).toLocal();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    throw ArgumentError.value(value, 'date', 'Unsupported date value');
  }

  @override
  List<Object?> get props => [
    date,
    dailyConsumedMl,
    dailyEntryCount,
    goalMl,
    createdAt,
  ];
}
