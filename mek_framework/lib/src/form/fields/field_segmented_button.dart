import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

class FieldSegmentedButton<T> extends FieldBuilder<Set<T>> with InlineFieldBuilder {
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final InputDecoration decoration;
  final List<ButtonSegment<T>> segments;

  const FieldSegmentedButton({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.decoration = FieldBuilder.decorationFlat,
    required this.segments,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<Set<T>> state) {
    final theme = BuiltFormTheme.of(context);
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    final child = InputDecorator(
      isFocused: hasFocus,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      child: SegmentedButton<T>(
        // TODO: focusNode: state.focusNode,
        multiSelectionEnabled: multiSelectionEnabled,
        emptySelectionAllowed: emptySelectionAllowed,
        selected: state.value,
        onSelectionChanged: isEnabled ? state.fieldBloc.changeValue : null,
        segments: segments,
      ),
    );
    return theme.wrap(child: child);
  }
}
