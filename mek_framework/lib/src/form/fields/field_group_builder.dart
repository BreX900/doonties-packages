import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';

class FieldGroupBuilder<T> extends FieldBuilder<T> with InlineFieldBuilder<T> {
  final EdgeInsetsGeometry padding;
  final InputDecoration decoration;
  final Widget Function(BuildContext context, FieldBuilderState<FieldBuilder<T>, T> state) builder;

  const FieldGroupBuilder({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.decoration = const InputDecoration(),
    required this.builder,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    final decoration = this.decoration.applyDefaults(const InputDecorationTheme(
          contentPadding: EdgeInsets.zero,
        ));

    return Focus(
      focusNode: focusNode,
      child: Padding(
        padding: padding,
        child: InputDecorator(
          isFocused: hasFocus,
          decoration: state.decorate(decoration, isEnabled: isEnabled),
          child: builder(context, state),
        ),
      ),
    );
  }
}
