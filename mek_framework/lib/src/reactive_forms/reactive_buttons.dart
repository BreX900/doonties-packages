import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveSaveButton extends SourceConsumerWidget {
  final Future<void> Function()? onSubmit;

  const ReactiveSaveButton({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, ConsumerScope scope) {
    final onSubmit = this.onSubmit;

    final field = context.findAncestorStateOfType<ReactiveFormFieldState>()!;

    final isPristine = scope.watch(field.control.source.pristine);
    if (isPristine) return const SizedBox.shrink();

    final submit =
        field.control.handleSubmitWith<Future<void> Function()>((submit) async => submit());
    return IconButton(
      onPressed: onSubmit != null ? () => submit(onSubmit) : null,
      icon: const Icon(Icons.save),
    );
  }
}

class ReactiveAddButton extends SourceConsumerWidget {
  final FutureOr<void> Function()? onSubmit;

  const ReactiveAddButton({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, ConsumerScope scope) {
    final onSubmit = this.onSubmit;

    final field = context.findAncestorStateOfType<ReactiveFormFieldState>()!;

    final isPristine = scope.watch(field.control.source.pristine);
    if (isPristine) return const SizedBox.shrink();

    final submit = field.control.handleSubmitWith<FutureOr<void> Function()>((submit) async {
      await submit();
      field.control.reset();
    });
    return IconButton(
      onPressed: onSubmit != null ? () => submit(onSubmit) : null,
      icon: const Icon(Icons.save),
    );
  }
}

class ReactiveClearButton extends SourceConsumerWidget {
  final VoidCallback? onClear;

  const ReactiveClearButton({super.key, this.onClear});

  @override
  Widget build(BuildContext context, ConsumerScope scope) {
    final field = context.findAncestorStateOfType<ReactiveFormFieldState>()!;
    final isEnabled = scope.watch(field.control.source.status.enabled);

    return IconButton(
      onPressed: isEnabled ? onClear ?? field.control.reset : null,
      icon: const Icon(Icons.clear),
    );
  }
}

class ReactiveEditButton extends SourceConsumerWidget {
  final ValueNotifier<FieldConfig> controller;
  final bool toggleableObscureText;
  final FutureOr<void> Function()? onSubmit;

  const ReactiveEditButton({
    super.key,
    required this.controller,
    this.toggleableObscureText = false,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, ConsumerScope scope) {
    final onSubmit = this.onSubmit;

    final field = context.findAncestorStateOfType<ReactiveFormFieldState>()!;
    final config = scope.watch(controller.source);

    final readOnly = config.readOnly;
    final submit = field.control.handleSubmitWith<FutureOr<void> Function()>((submit) async {
      await submit();
      controller.value = config.copyWith(readOnly: true);
    });

    return IconButton(
      onPressed: readOnly
          ? () => controller.value = config.copyWith(readOnly: false)
          : (onSubmit != null ? () => submit(onSubmit) : null),
      icon: readOnly ? const Icon(Icons.edit_outlined) : const Icon(Icons.check),
    );
  }
}

class ReactiveVisibilityButton extends SourceConsumerWidget {
  final ValueNotifier<TextConfig> controller;

  const ReactiveVisibilityButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context, ConsumerScope scope) {
    final config = scope.watch(controller.source);
    return IconButton(
      onPressed: () => controller.value = config.copyWith(obscureText: !config.obscureText),
      icon: config.obscureText ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
    );
  }
}

class VisibilityButton extends ConsumerWidget {
  final bool value;
  final ValueChanged<bool> onChange;

  const VisibilityButton({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () => onChange(!value),
      icon: value ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
    );
  }
}
