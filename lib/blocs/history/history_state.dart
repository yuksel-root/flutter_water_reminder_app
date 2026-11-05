import 'package:equatable/equatable.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

enum HistoryStatus { initial, loading, ready, failure }

class HistoryState extends Equatable {
  const HistoryState({
    required this.startDate,
    required this.endDate,
    this.status = HistoryStatus.initial,
    this.history = const [],
    this.errorMessage = '',
  });

  factory HistoryState.initial() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(const Duration(days: 6));

    return HistoryState(startDate: start, endDate: end);
  }

  final DateTime startDate;
  final DateTime endDate;
  final HistoryStatus status;
  final List<WaterHistory> history;
  final String errorMessage;

  int get totalConsumedMl =>
      history.fold(0, (total, item) => total + item.dailyConsumedMl);

  int get totalEntryCount =>
      history.fold(0, (total, item) => total + item.dailyEntryCount);

  double get averageDailyMl =>
      history.isEmpty ? 0 : totalConsumedMl / history.length;

  HistoryState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    HistoryStatus? status,
    List<WaterHistory>? history,
    String? errorMessage,
  }) {
    return HistoryState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    status,
    history,
    errorMessage,
  ];
}
