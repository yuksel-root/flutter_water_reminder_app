import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/add_water/add_water_state.dart';

class AddWaterCubit extends Cubit<AddWaterState> {
  AddWaterCubit() : super(AddWaterState.initial());

  void selectContainer(WaterContainer container) {
    final amount = container == WaterContainer.custom
        ? ''
        : container.defaultMl.toString();
    emit(
      state.copyWith(container: container, amount: amount, clearError: true),
    );
  }

  void amountChanged(String value) {
    emit(state.copyWith(amount: value, clearError: true));
  }

  int? validate() {
    final value = int.tryParse(state.amount.trim());
    if (value == null || value <= 0) {
      emit(state.copyWith(errorMessage: 'Enter an amount greater than zero'));
      return null;
    }
    return value;
  }
}
