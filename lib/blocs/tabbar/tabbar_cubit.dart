import 'package:flutter_bloc/flutter_bloc.dart';

class TabbarCubit extends Cubit<int> {
  TabbarCubit() : super(0);

  void select(int index) {
    if (index == state) return;
    emit(index);
  }
}
