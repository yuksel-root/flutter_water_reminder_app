import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_event.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_repository.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._repository) : super(HistoryState.initial()) {
    on<HistoryStarted>(_onStarted);
    on<HistoryRefreshed>(_onRefreshed);
    on<HistoryRangeChanged>(_onRangeChanged);
  }

  final HistoryRepository _repository;

  Future<void> _onStarted(HistoryStarted event, Emitter<HistoryState> emit) =>
      _load(emit);

  Future<void> _onRefreshed(
    HistoryRefreshed event,
    Emitter<HistoryState> emit,
  ) => _load(emit);

  Future<void> _onRangeChanged(
    HistoryRangeChanged event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        errorMessage: '',
      ),
    );
    await _load(emit);
  }

  Future<void> _load(Emitter<HistoryState> emit) async {
    emit(state.copyWith(status: HistoryStatus.loading, errorMessage: ''));

    try {
      final items = await _repository.fetchHistory(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      emit(
        state.copyWith(
          status: HistoryStatus.ready,
          history: items,
          errorMessage: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HistoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
