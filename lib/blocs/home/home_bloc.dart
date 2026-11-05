import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_event.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_repository.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_state.dart';
import 'package:flutter_water_reminder_app/models/water/water_entry.dart';
import 'package:flutter_water_reminder_app/models/water/water_goal.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeWaterAdded>(_onWaterAdded);
    on<HomeGoalUpdated>(_onGoalUpdated);
  }

  final HomeRepository _repository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) =>
      _load(emit);

  Future<void> _onRefreshed(HomeRefreshed event, Emitter<HomeState> emit) =>
      _load(emit);

  Future<void> _onWaterAdded(
    HomeWaterAdded event,
    Emitter<HomeState> emit,
  ) async {
    if (event.amountMl <= 0) return;

    try {
      await _repository.addEntry(
        WaterEntry(consumedMl: event.amountMl, createdAt: DateTime.now()),
      );
      await _load(emit);
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onGoalUpdated(
    HomeGoalUpdated event,
    Emitter<HomeState> emit,
  ) async {
    if (event.targetMl <= 0) return;

    try {
      final now = DateTime.now();
      final current = state.activeGoal;
      final goal = current == null
          ? WaterGoal(
              targetMl: event.targetMl,
              period: WaterGoalPeriod.daily,
              startDate: now,
              createdAt: now,
            )
          : current.copyWith(targetMl: event.targetMl, updatedAt: now);

      final saved = await _repository.saveGoal(goal);
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          activeGoal: saved,
          errorMessage: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _load(Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: ''));

    try {
      final entries = await _repository.fetchTodayEntries();
      final goal = await _repository.fetchActiveGoal();

      emit(
        state.copyWith(
          status: HomeStatus.ready,
          entries: entries,
          activeGoal: goal,
          errorMessage: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
