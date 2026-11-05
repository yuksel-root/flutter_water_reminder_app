import 'package:equatable/equatable.dart';

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
