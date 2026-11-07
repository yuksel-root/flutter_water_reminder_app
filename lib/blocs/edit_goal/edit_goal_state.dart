import 'package:equatable/equatable.dart';

class EditGoalState extends Equatable {
  const EditGoalState({required this.amount, this.errorMessage});

  factory EditGoalState.initial(int goalMl) {
    return EditGoalState(amount: goalMl.toString());
  }

  final String amount;
  final String? errorMessage;

  EditGoalState copyWith({
    String? amount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EditGoalState(
      amount: amount ?? this.amount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [amount, errorMessage];
}
