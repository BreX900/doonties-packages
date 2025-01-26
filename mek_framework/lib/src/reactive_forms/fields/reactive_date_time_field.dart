import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mek/src/form/date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveDateTimeField extends ReactiveFocusableFormField<DateTime?, DateTime> {
  ReactiveDateTimeField({
    super.key,
    required FormControl<DateTime?> super.formControl,
    bool readOnly = false,
    DateFormat? format,
    Future<DateTime?> Function(BuildContext context, DateTime value)? picker,
    InputDecoration decoration = const InputDecoration(),
    DateTime? initialDate,
  }) : super(
          builder: (field) {
            final theme = Theme.of(field.context);
            format ??= DateFormat(null, Localizations.localeOf(field.context).languageCode);

            final isEnabled = field.control.enabled;
            final canEdit = isEnabled && !readOnly;

            Future<void> changeValue() async {
              final initialValue = field.value ?? initialDate ?? DateTime.now();

              final value =
                  await (picker ?? const DateTimePicker().call)(field.context, initialValue);
              if (value == null || !field.mounted) return;

              field.didChange(value);
            }

            final decorationTheme = Theme.of(field.context).inputDecorationTheme;

            final child = InputDecorator(
              decoration: decoration.copyWith(
                enabled: isEnabled,
                errorText: field.errorText,
              ),
              isEmpty: field.value == null,
              isFocused: field.focusNode?.hasFocus ?? false,
              child: Text(
                field.value == null ? '' : format!.format(field.value!),
                style: isEnabled ? null : TextStyle(color: theme.disabledColor),
              ),
            );
            return InkWell(
              focusNode: field.focusNode,
              onTap: canEdit ? changeValue : null,
              customBorder: decoration.border ?? decorationTheme.border,
              child: child,
            );
          },
        );
}
