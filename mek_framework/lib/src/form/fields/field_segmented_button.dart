import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';
import 'package:mek/src/form/shared/field_converter.dart';

class FieldSegmentedButton<T> extends FieldBuilder<dynamic> with InlineFieldBuilder {
  final FieldConverter<dynamic, Set<T>> converter;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final InputDecoration decoration;
  final List<ButtonSegment<T>> segments;

  @Deprecated('In favour of reactive_forms')
  const FieldSegmentedButton({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    required this.converter,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.decoration = FieldBuilder.decorationFlat,
    required this.segments,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<dynamic> state) {
    final theme = BuiltFormTheme.of(context);
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    void changeValue(Set<T> value) {
      state.fieldBloc.changeValue(converter.convertForBloc(state.fieldBloc, value));
    }

    final child = InputDecorator(
      isFocused: hasFocus,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: SegmentedButton<T>(
          // TODO: focusNode: state.focusNode,
          multiSelectionEnabled: multiSelectionEnabled,
          emptySelectionAllowed: emptySelectionAllowed,
          showSelectedIcon: showSelectedIcon,
          selected: converter.convertForView(state.fieldBloc, state.value),
          onSelectionChanged: isEnabled ? changeValue : null,
          segments: segments,
        ),
      ),
    );
    return theme.wrap(child: child);
  }
}
