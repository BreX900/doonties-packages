import 'package:chips_input/chips_input.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

class FieldChipsInput<T extends Object> extends FieldBuilder<IList<T>> with InlineFieldBuilder {
  final InputDecoration decoration;
  final ChipsInputSuggestions<T> findSuggestions;
  final Widget Function(BuildContext context, T value) labelBuilder;
  final ChipsBuilder<T>? chipBuilder;
  final Widget Function(BuildContext context, T value)? suggestionBuilder;

  const FieldChipsInput({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    this.decoration = const InputDecoration(),
    required this.findSuggestions,
    this.labelBuilder = _defaultLabelBuilder,
    this.chipBuilder,
    this.suggestionBuilder,
  });

  static Widget _defaultLabelBuilder(BuildContext context, Object? value) => Text('$value');

  Widget _buildSuggestions(BuildContext context, ValueSetter<T> select, Iterable<T> suggestions) {
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: suggestions.map((value) {
                if (suggestionBuilder != null) {
                  return InkWell(
                    onTap: () => select(value),
                    child: suggestionBuilder!(context, value),
                  );
                }
                return ListTile(
                  onTap: () => select(value),
                  title: labelBuilder(context, value),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, ChipsInputState<T> state, T value) {
    if (chipBuilder != null) return chipBuilder!(context, state, value);

    return Chip(
      onDeleted: () => state.deleteChip(value),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      label: labelBuilder(context, value),
    );
  }

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<IList<T>> state) {
    final theme = BuiltFormTheme.of(context);
    final isEnabled = state.isEnabled;

    void changeValue(List<T> value) {
      state.fieldBloc.changeValue(value.toIList());
      state.completeEditing();
    }

    final child = ChipsInput<T>(
      focusNode: state.focusNode,
      enabled: isEnabled,
      onChanged: changeValue,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      initialValue: state.value.asList(),
      findSuggestions: findSuggestions,
      chipBuilder: _buildChip,
      optionsViewBuilder: (context, select, value) {
        return _buildSuggestions(context, (value) {
          select(value);
          state.completeEditing();
        }, value);
      },
    );
    return theme.wrap(child: child);
  }
}
