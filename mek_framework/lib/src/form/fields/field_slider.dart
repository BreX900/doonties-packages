import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

class FieldSlider extends FieldBuilder<double> with InlineFieldBuilder {
  final double min;
  final double max;
  final int? divisions;
  final InputDecoration decoration;
  final String Function(double value)? labelBuilder;

  const FieldSlider({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.decoration = const InputDecoration(),
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<double> state) {
    final theme = BuiltFormTheme.of(context);
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    final child = InputDecorator(
      isFocused: hasFocus,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      child: Slider(
        focusNode: state.focusNode,
        value: state.value,
        onChanged: isEnabled ? state.fieldBloc.changeValue : null,
        min: min,
        max: max,
        divisions: divisions,
        label: labelBuilder?.call(state.value),
      ),
    );
    return theme.wrap(child: child);
  }
}
