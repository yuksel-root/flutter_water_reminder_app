import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/edit_goal/edit_goal_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/edit_goal/edit_goal_state.dart';

Future<int?> showEditGoalDialog(BuildContext context, int currentGoalMl) {
  return showDialog<int>(
    context: context,
    builder: (context) => BlocProvider(
      create: (_) => EditGoalCubit(currentGoalMl),
      child: const EditGoalDialog(),
    ),
  );
}

class EditGoalDialog extends StatelessWidget {
  const EditGoalDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EditGoalDialogView();
  }
}

class _EditGoalDialogView extends StatefulWidget {
  const _EditGoalDialogView();

  @override
  State<_EditGoalDialogView> createState() => _EditGoalDialogViewState();
}

class _EditGoalDialogViewState extends State<_EditGoalDialogView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<EditGoalCubit>().state.amount,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = context.read<EditGoalCubit>().validate();
    if (value == null) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditGoalCubit, EditGoalState>(
      listenWhen: (previous, current) => previous.amount != current.amount,
      listener: (context, state) {
        if (_controller.text == state.amount) return;
        _controller.value = TextEditingValue(
          text: state.amount,
          selection: TextSelection.collapsed(offset: state.amount.length),
        );
      },
      child: BlocBuilder<EditGoalCubit, EditGoalState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Daily goal'),
            content: TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Goal',
                suffixText: 'ml',
                errorText: state.errorMessage,
              ),
              onChanged: (value) =>
                  context.read<EditGoalCubit>().amountChanged(value),
              onSubmitted: (_) => _save(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          );
        },
      ),
    );
  }
}
