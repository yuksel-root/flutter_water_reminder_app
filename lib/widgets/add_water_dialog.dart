import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/add_water/add_water_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/add_water/add_water_state.dart';

Future<int?> showAddWaterDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) => BlocProvider(
      create: (_) => AddWaterCubit(),
      child: const AddWaterDialog(),
    ),
  );
}

class AddWaterDialog extends StatelessWidget {
  const AddWaterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AddWaterDialogView();
  }
}

class _AddWaterDialogView extends StatefulWidget {
  const _AddWaterDialogView();

  @override
  State<_AddWaterDialogView> createState() => _AddWaterDialogViewState();
}

class _AddWaterDialogViewState extends State<_AddWaterDialogView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AddWaterCubit>().state.amount,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final amount = context.read<AddWaterCubit>().validate();
    if (amount == null) return;
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddWaterCubit, AddWaterState>(
      listenWhen: (previous, current) => previous.amount != current.amount,
      listener: (context, state) {
        if (_controller.text == state.amount) return;
        _controller.value = TextEditingValue(
          text: state.amount,
          selection: TextSelection.collapsed(offset: state.amount.length),
        );
      },
      child: BlocBuilder<AddWaterCubit, AddWaterState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Text('Custom amount'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: WaterContainer.values.map((container) {
                      return ChoiceChip(
                        label: Text(container.label),
                        selected: state.container == container,
                        onSelected: (_) => context
                            .read<AddWaterCubit>()
                            .selectContainer(container),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      suffixText: 'ml',
                      errorText: state.errorMessage,
                    ),
                    onChanged: (value) =>
                        context.read<AddWaterCubit>().amountChanged(value),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(onPressed: _save, child: const Text('Add')),
            ],
          );
        },
      ),
    );
  }
}
