import 'package:equatable/equatable.dart';
import 'package:flutter_water_reminder_app/models/water/water_history.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

final class HistoryStarted extends HistoryEvent {
  const HistoryStarted();
}

final class HistoryRefreshed extends HistoryEvent {
  const HistoryRefreshed();
}

final class HistoryRangeChanged extends HistoryEvent {
  const HistoryRangeChanged({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [startDate, endDate];
}

final class HistoryRemoteUpdated extends HistoryEvent {
  const HistoryRemoteUpdated({
    required this.history,
    required this.startDate,
    required this.endDate,
  });

  final List<WaterHistory> history;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [history, startDate, endDate];
}
