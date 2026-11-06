import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum WaterContainer {
  glass('Glass', 200),
  cup('Cup', 250),
  bottle('Bottle', 500),
  custom('Custom', 0);

  const WaterContainer(this.label, this.defaultMl);

  final String label;
  final int defaultMl;
}

Future<int?> showAddWaterDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (context) => const AddWaterDialog(),
  );
}

class AddWaterDialog extends StatefulWidget {
  const AddWaterDialog({super.key});

  @override
  State<AddWaterDialog> createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends State<AddWaterDialog> {
  late final TextEditingController _controller;
  WaterContainer _container = WaterContainer.glass;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _container.defaultMl.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectContainer(WaterContainer container) {
    setState(() {
      _container = container;
      _controller.text = container.defaultMl == 0
          ? ''
          : container.defaultMl.toString();
      _errorText = null;
    });
  }

  void _save() {
    final value = int.tryParse(_controller.text.trim());

    if (value == null || value <= 0) {
      setState(() => _errorText = 'Enter an amount greater than zero');
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom amount'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a container',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WaterContainer.values.map((container) {
                return ChoiceChip(
                  label: Text(
                    container.defaultMl == 0
                        ? container.label
                        : '${container.label} ${container.defaultMl} ml',
                  ),
                  selected: _container == container,
                  onSelected: (_) => _selectContainer(container),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Amount',
                suffixText: 'ml',
                errorText: _errorText,
              ),
              onSubmitted: (_) => _save(),
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
  }
}
