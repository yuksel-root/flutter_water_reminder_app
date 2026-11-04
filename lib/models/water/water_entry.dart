import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WaterEntry extends Equatable {
  const WaterEntry({this.id, required this.consumedMl, required this.createdAt})
    : assert(consumedMl > 0);

  final String? id;
  final int consumedMl;
  final DateTime createdAt;

  DateTime get date => DateTime(createdAt.year, createdAt.month, createdAt.day);

  String get dateKey {
    final year = createdAt.year.toString().padLeft(4, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  factory WaterEntry.fromMap(Map<String, dynamic> map, {String? id}) {
    return WaterEntry(
      id: id,
      consumedMl: (map['consumedMl'] as num).toInt(),
      createdAt: _dateTimeFrom(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'consumedMl': consumedMl,
      'createdAt': Timestamp.fromDate(createdAt),
      'date': dateKey,
    };
  }

  WaterEntry copyWith({String? id, int? consumedMl, DateTime? createdAt}) {
    return WaterEntry(
      id: id ?? this.id,
      consumedMl: consumedMl ?? this.consumedMl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime _dateTimeFrom(dynamic value) {
    if (value is Timestamp) return value.toDate().toLocal();
    if (value is DateTime) return value.toLocal();
    if (value is String) return DateTime.parse(value).toLocal();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    throw ArgumentError.value(value, 'createdAt', 'Unsupported date value');
  }

  @override
  List<Object?> get props => [id, consumedMl, createdAt];
}
