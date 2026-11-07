import 'package:equatable/equatable.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';

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

final class HomeRemoteUpdated extends HomeEvent {
  const HomeRemoteUpdated({required this.entries, required this.activeGoal});

  final List<WaterEntry> entries;
  final WaterGoal? activeGoal;

  @override
  List<Object?> get props => [entries, activeGoal];
}
