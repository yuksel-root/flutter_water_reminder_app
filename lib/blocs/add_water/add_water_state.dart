import 'package:equatable/equatable.dart';

enum WaterContainer {
  glass('Glass', 200),
  cup('Cup', 250),
  bottle('Bottle', 500),
  custom('Custom', 0);

  const WaterContainer(this.label, this.defaultMl);

  final String label;
  final int defaultMl;
}

class AddWaterState extends Equatable {
  const AddWaterState({
    required this.container,
    required this.amount,
    this.errorMessage,
  });

  factory AddWaterState.initial() {
    return AddWaterState(
      container: WaterContainer.glass,
      amount: WaterContainer.glass.defaultMl.toString(),
    );
  }

  final WaterContainer container;
  final String amount;
  final String? errorMessage;

  AddWaterState copyWith({
    WaterContainer? container,
    String? amount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddWaterState(
      container: container ?? this.container,
      amount: amount ?? this.amount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [container, amount, errorMessage];
}
