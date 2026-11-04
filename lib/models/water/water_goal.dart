import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum WaterGoalPeriod {
  daily,
  weekly,
  monthly;

  static WaterGoalPeriod fromValue(String? value) {
    return WaterGoalPeriod.values.firstWhere(
      (period) => period.name == value,
      orElse: () => WaterGoalPeriod.daily,
    );
  }
}

class WaterGoal extends Equatable {
  const WaterGoal({
    this.id,
    required this.targetMl,
    required this.period,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  }) : assert(targetMl > 0);

  final String? id;
  final int targetMl;
  final WaterGoalPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  bool isActiveOn(DateTime date) {
    if (!isActive) return false;

    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDate == null
        ? null
        : DateTime(endDate!.year, endDate!.month, endDate!.day);

    return !day.isBefore(start) && (end == null || !day.isAfter(end));
  }

  factory WaterGoal.fromMap(Map<String, dynamic> map, {String? id}) {
    return WaterGoal(
      id: id,
      targetMl: (map['targetMl'] as num).toInt(),
      period: WaterGoalPeriod.fromValue(map['period'] as String?),
      startDate: _dateTimeFrom(map['startDate']),
      endDate: _dateTimeOrNull(map['endDate']),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: _dateTimeFrom(map['createdAt']),
      updatedAt: _dateTimeOrNull(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetMl': targetMl,
      'period': period.name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  WaterGoal copyWith({
    String? id,
    int? targetMl,
    WaterGoalPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterGoal(
      id: id ?? this.id,
      targetMl: targetMl ?? this.targetMl,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _dateTimeFrom(dynamic value) {
    final date = _dateTimeOrNull(value);
    if (date == null) {
      throw ArgumentError.value(value, 'date', 'Unsupported date value');
    }
    return date;
  }

  static DateTime? _dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toLocal();
    if (value is DateTime) return value.toLocal();
    if (value is String) return DateTime.parse(value).toLocal();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    throw ArgumentError.value(value, 'date', 'Unsupported date value');
  }

  @override
  List<Object?> get props => [
    id,
    targetMl,
    period,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
}
