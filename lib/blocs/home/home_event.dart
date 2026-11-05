import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

final class HomeWaterAdded extends HomeEvent {
  const HomeWaterAdded(this.amountMl);

  final int amountMl;

  @override
  List<Object?> get props => [amountMl];
}

final class HomeGoalUpdated extends HomeEvent {
  const HomeGoalUpdated(this.targetMl);

  final int targetMl;

  @override
  List<Object?> get props => [targetMl];
}
