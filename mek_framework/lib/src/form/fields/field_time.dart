import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

class FieldTime<T extends TimeOfDay?> extends FieldBuilder<T> with InlineFieldBuilder {
  final InputDecoration decoration;

  /// Default: [TimeOfDay.now]
  final TimeOfDay? initialTime;

  const FieldTime({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    this.decoration = const InputDecoration(),
    this.initialTime,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final theme = BuiltFormTheme.of(context);
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    Future<void> changeValue() async {
      final value = await showTimePicker(
        context: context,
        initialTime: initialTime ?? TimeOfDay.now(),
      );
      if (value == null) return;
      state.fieldBloc.updateValue(value as T);
      state.completeEditing();
    }

    final child = InkWell(
      focusNode: state.focusNode,
      onTap: isEnabled ? changeValue : null,
      child: InputDecorator(
        decoration: state.decorate(decoration, isEnabled: isEnabled),
        isEmpty: state.value == null,
        isFocused: hasFocus,
        child: Text(state.value?.format(context) ?? ''),
      ),
    );
    return theme.wrap(child: child);
  }
}
