import 'package:equatable/equatable.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';

enum HomeStatus { initial, loading, ready, failure }

const Object _unset = Object();

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.entries = const [],
    this.activeGoal,
    this.errorMessage = '',
  });

  final HomeStatus status;
  final List<WaterEntry> entries;
  final WaterGoal? activeGoal;
  final String errorMessage;

  static const int defaultGoalMl = 2000;

  int get consumedMl =>
      entries.fold(0, (total, entry) => total + entry.consumedMl);

  int get goalMl => activeGoal?.targetMl ?? defaultGoalMl;

  int get remainingMl {
    final value = goalMl - consumedMl;
    return value < 0 ? 0 : value;
  }

  double get progress {
    if (goalMl <= 0) return 0;
    final value = consumedMl / goalMl;
    return value > 1 ? 1 : value;
  }

  HomeState copyWith({
    HomeStatus? status,
    List<WaterEntry>? entries,
    Object? activeGoal = _unset,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      activeGoal: identical(activeGoal, _unset)
          ? this.activeGoal
          : activeGoal as WaterGoal?,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, activeGoal, errorMessage];
}
