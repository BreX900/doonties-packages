import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/group_style.dart';
import 'package:mek/src/form/shared/group_view.dart';

class FieldGroupBuilder<T> extends FieldBuilder<T> with InlineFieldBuilder<T> {
  final int valuesCount;
  final EdgeInsetsGeometry padding;
  final InputDecoration decoration;
  final GroupStyle style;
  final Widget Function(BuildContext context, Widget child)? builder;
  final Widget Function(FieldBuilderState<FieldBuilder<T>, T> state, int index) valueBuilder;

  const FieldGroupBuilder({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    required this.valuesCount,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.decoration = const InputDecoration(),
    this.style = const FlexGroupStyle(),
    this.builder,
    required this.valueBuilder,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    final values = GroupView(
      style: style,
      count: valuesCount,
      builder: (context, index) => valueBuilder(state, index),
    );

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
          child: builder?.call(context, values) ?? values,
        ),
      ),
    );
  }
}
