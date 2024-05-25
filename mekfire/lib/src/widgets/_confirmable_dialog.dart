import 'package:flutter/material.dart';
import 'package:mek/mek.dart';

class ConfirmableDialog extends StatelessWidget with TypedWidgetMixin<bool> {
  final Widget title;
  final Widget? content;
  final Widget positive;

  const ConfirmableDialog({
    super.key,
    required this.title,
    this.content,
    required this.positive,
  });

  const ConfirmableDialog.delete({
    super.key,
    required this.title,
    this.content,
  }) : positive = const Text('Delete');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () => pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => pop(context, true),
          child: positive,
        ),
      ],
    );
  }
}
