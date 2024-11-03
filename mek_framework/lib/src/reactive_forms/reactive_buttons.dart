import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/reactive_forms/form_control_state_provider.dart';
import 'package:mek/src/reactive_forms/reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveSaveFieldButton extends ConsumerWidget {
  final FormControl<Object?> formControl;
  final VoidCallback? onSubmit;

  const ReactiveSaveFieldButton({
    super.key,
    required this.formControl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSubmit = this.onSubmit;

    final isPristine = ref.watch(formControl.provider.pristine);
    if (isPristine) return const SizedBox.shrink();

    final submit = formControl.handleSubmit<VoidCallback>((submit) => submit());
    return IconButton(
      onPressed: onSubmit != null ? () => submit(onSubmit) : null,
      icon: const Icon(Icons.save),
    );
  }
}
