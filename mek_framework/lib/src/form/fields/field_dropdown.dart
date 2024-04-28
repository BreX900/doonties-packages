import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

class FieldDropdown<T> extends FieldBuilder<T> with InlineFieldBuilder {
  final EdgeInsetsGeometry? padding;
  final InputDecoration decoration;
  final ValueChanged<T>? onChanged;
  final List<DropdownMenuItem<T>> items;

  const FieldDropdown({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.padding,
    required this.items,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final isEnabled = state.isEnabled;

    void changeValue(T? value) {
      state.fieldBloc.changeValue(value as T);
      state.completeEditing();
      onChanged?.call(value);
    }

    return DropdownButtonFormField<T>(
      focusNode: state.focusNode,
      value: state.value,
      onChanged: isEnabled ? changeValue : null,
      items: items,
      padding: padding ?? BuiltFormTheme.of(context).fieldPadding,
      isExpanded: true,
      selectedItemBuilder: (context) {
        return items.map((e) {
          return DefaultTextStyle.merge(
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
            child: e,
          );
        }).toList();
      },
      decoration: state.decorate(decoration, isEnabled: isEnabled),
    );
  }
}
