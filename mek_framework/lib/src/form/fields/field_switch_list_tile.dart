import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';

class FieldSwitchListTile extends FieldBuilder<bool> with InlineFieldBuilder {
  final bool dense;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? title;
  final Widget? subtitle;

  @Deprecated('In favour of reactive_forms')
  const FieldSwitchListTile({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    this.dense = false,
    this.contentPadding,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<bool> state) {
    final isEnabled = state.isEnabled;

    return SwitchListTile(
      focusNode: state.focusNode,
      value: state.value,
      onChanged: isEnabled ? state.fieldBloc.changeValue : null,
      dense: dense,
      contentPadding: contentPadding,
      title: title,
      subtitle: subtitle,
    );
  }
}
