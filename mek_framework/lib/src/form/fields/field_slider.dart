import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';
import 'package:mek/src/form/shared/field_converter.dart';

class FieldSlider<T> extends FieldBuilder<T> with InlineFieldBuilder {
  final FieldConverter<T, double> converter;
  final double min;
  final double max;
  final int? divisions;
  final EdgeInsetsGeometry? padding;
  final InputDecoration decoration;
  final String Function(double value)? labelBuilder;

  @Deprecated('In favour of reactive_forms')
  const FieldSlider({
    super.key,
    required super.fieldBloc,
    required this.converter,
    super.focusNode,
    super.errorTranslator,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.padding,
    this.decoration = const InputDecoration(),
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final theme = BuiltFormTheme.of(context);
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    final value = converter.convertForView(state.fieldBloc, state.value);

    void changeValue(double value) {
      state.fieldBloc.changeValue(converter.convertForBloc(state.fieldBloc, value));
    }

    final child = InputDecorator(
      isFocused: hasFocus,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      child: Slider(
        focusNode: state.focusNode,
        value: value,
        onChanged: isEnabled ? changeValue : null,
        min: min,
        max: max,
        divisions: divisions,
        label: labelBuilder?.call(value),
      ),
    );
    return theme.wrap(padding: padding, child: child);
  }
}
