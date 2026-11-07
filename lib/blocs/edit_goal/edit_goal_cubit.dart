import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/edit_goal/edit_goal_state.dart';

class EditGoalCubit extends Cubit<EditGoalState> {
  EditGoalCubit(int initialGoalMl)
    : super(EditGoalState.initial(initialGoalMl));

  void amountChanged(String value) {
    emit(state.copyWith(amount: value, clearError: true));
  }

  int? validate() {
    final value = int.tryParse(state.amount.trim());
    if (value == null || value <= 0) {
      emit(state.copyWith(errorMessage: 'Enter a goal greater than zero'));
      return null;
    }
    return value;
  }
}
