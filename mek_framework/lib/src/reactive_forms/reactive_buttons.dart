import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/reactive_forms/form_control_state_provider.dart';
import 'package:mek/src/reactive_forms/reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveSaveButton extends ConsumerWidget {
  final VoidCallback? onSubmit;

  const ReactiveSaveButton({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSubmit = this.onSubmit;

    final field = context.findAncestorStateOfType<ReactiveFormFieldState>()!;

    final isPristine = ref.watch(field.control.provider.pristine);
    if (isPristine) return const SizedBox.shrink();

    final submit = field.control.handleSubmit<VoidCallback>((submit) => submit());
    return IconButton(
      onPressed: onSubmit != null ? () => submit(onSubmit) : null,
      icon: const Icon(Icons.save),
    );
  }
}

class ReactiveClearButton extends ConsumerWidget {
  final bool disableOnReadOnly;

  const ReactiveClearButton({
    super.key,
    this.disableOnReadOnly = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = context.findAncestorStateOfType<ReactiveFormFieldState>()!;
    final isEnabled = ref.watch(field.control.provider.status.enabled);

    return IconButton(
      onPressed: isEnabled ? () => field.control.reset(removeFocus: true) : null,
      icon: const Icon(Icons.clear),
    );
  }
}
