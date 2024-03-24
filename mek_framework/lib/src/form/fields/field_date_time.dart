import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

class FieldDateTime<T extends DateTime?> extends FieldBuilder<T> with InlineFieldBuilder<T> {
  final bool readOnly;
  final InputDecoration decoration;
  final DateFormat? format;
  final Future<DateTime?> Function(BuildContext context, DateTime value)? picker;

  /// Default: [DateTime.now]
  final DateTime? initialDate;

  const FieldDateTime({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.format,
    this.picker,
    this.initialDate,
  });

  const FieldDateTime.from({
    super.key,
    required super.value,
    this.decoration = const InputDecoration(),
    this.format,
    this.initialDate,
  })  : readOnly = true,
        picker = null,
        super.from();

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final format = this.format ?? DateFormat(null, Localizations.localeOf(context).languageCode);
    final theme = BuiltFormTheme.of(context);

    final isEnabled = state.isEnabled;
    final canEdit = isEnabled && !readOnly;
    final hasFocus = state.watchHasFocus();

    Future<void> changeValue() async {
      final initialValue = state.value ?? initialDate ?? DateTime.now();

      final value = await (picker ?? const DateTimePicker().call)(context, initialValue);
      if (value == null || !state.mounted) return;

      state.fieldBloc.changeValue(value as T);
      state.completeEditing();
    }

    final decorationTheme = Theme.of(context).inputDecorationTheme;

    final child = InputDecorator(
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      isEmpty: state.value == null,
      isFocused: hasFocus,
      child: Text(state.value == null ? '' : format.format(state.value!)),
    );
    return InkWell(
      focusNode: state.focusNode,
      onTap: canEdit ? changeValue : null,
      customBorder: decoration.border ?? decorationTheme.border,
      child: theme.wrap(child: child),
    );
  }
}

class DateTimePicker {
  final bool _shouldPickTime;

  const DateTimePicker() : _shouldPickTime = true;

  const DateTimePicker.date() : _shouldPickTime = false;

  Future<DateTime?> _pickDate(BuildContext context, DateTime value) async {
    return await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(1000),
      lastDate: DateTime(3000),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext context, DateTime value) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
  }

  Future<DateTime?> call(BuildContext context, DateTime prevValue) async {
    var currValue = prevValue;

    final date = await _pickDate(context, prevValue);
    if (!context.mounted || date == null) return null;

    currValue = date;

    if (_shouldPickTime) {
      final time = await _pickTime(context, prevValue);
      if (!context.mounted || time == null) return null;

      currValue = currValue.copyWith(hour: time.hour, minute: time.minute);
    }

    return currValue;
  }
}
