import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<int?> showEditGoalDialog(BuildContext context, int currentGoalMl) {
  return showDialog<int>(
    context: context,
    builder: (context) => EditGoalDialog(initialGoalMl: currentGoalMl),
  );
}

class EditGoalDialog extends StatefulWidget {
  const EditGoalDialog({super.key, required this.initialGoalMl});

  final int initialGoalMl;

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialGoalMl.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = int.tryParse(_controller.text.trim());

    if (value == null || value <= 0) {
      setState(() => _errorText = 'Enter a goal greater than zero');
      return;
    }

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
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
          errorText: _errorText,
        ),
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
  }
}
