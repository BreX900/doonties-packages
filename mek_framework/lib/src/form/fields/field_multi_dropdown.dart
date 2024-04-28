import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';
import 'package:mek/src/form/shared/field_converter.dart';

class FieldMultiDropdown<TBlocValue, TViewValue> extends FieldBuilder<TBlocValue>
    with InlineFieldBuilder {
  final FieldConverter<TBlocValue, ISet<TViewValue>> converter;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final InputDecoration? decoration;
  final ValueChanged<TViewValue>? onChanged;
  final List<PopupMenuEntry<TViewValue>> Function(BuildContext context, ISet<TViewValue> selection)
      itemsBuilder;
  final Widget Function(BuildContext context, ISet<TViewValue> selection)? builder;
  final Widget? icon;

  const FieldMultiDropdown({
    super.key,
    required super.fieldBloc,
    required this.converter,
    super.focusNode,
    super.errorTranslator,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.padding,
    this.constraints,
    required this.itemsBuilder,
    this.builder,
    this.icon,
  }) : assert(builder == null || icon == null);

  FieldMultiDropdown.withChip({
    super.key,
    required super.fieldBloc,
    required this.converter,
    super.focusNode,
    super.errorTranslator,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.padding,
    this.constraints,
    required List<PopupMenuItem<TViewValue>> Function(
            BuildContext context, ISet<TViewValue> selection)
        this.itemsBuilder,
  })  : icon = null,
        builder = ((context, selection) {
          final items = itemsBuilder(context, selection);

          return Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: selection.map((selected) {
                final item = items.firstWhere((e) => e.represents(selected));

                return Chip(
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.only(left: 8.0),
                  onDeleted: () => fieldBloc
                      .changeValue(converter.convertForBloc(fieldBloc, selection.remove(selected))),
                  label: item.child ?? const SizedBox.shrink(),
                );
              }).toList(),
            ),
          );
        });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<TBlocValue> state) {
    final theme = Theme.of(context);
    final formTheme = BuiltFormTheme.of(context);
    final isEnabled = state.isEnabled;

    final viewValue = converter.convertForView(state.fieldBloc, state.value);

    void changeValue(TViewValue value) {
      final newViewValue =
          viewValue.contains(value) ? viewValue.remove(value) : viewValue.add(value);
      final newBlocValue = converter.convertForBloc(state.fieldBloc, newViewValue);
      state.fieldBloc.changeValue(newBlocValue);
      state.completeEditing();
      onChanged?.call(value);
    }

    Widget buildChild(Widget Function(BuildContext context, ISet<TViewValue> selection) builder) {
      final child = InputDecorator(
        isEmpty: viewValue.isEmpty,
        decoration: state.decorate(decoration!, isEnabled: isEnabled),
        child: builder(context, viewValue),
      );
      return ConstrainedBox(
        constraints: constraints ?? const BoxConstraints(minHeight: kToolbarHeight),
        child: formTheme.wrap(
          padding: padding,
          child: child,
        ),
      );
    }

    return PopupMenuButton<TViewValue>(
      onSelected: changeValue,
      enabled: isEnabled,
      constraints: constraints,
      // focusNode: state.focusNode,
      // onOptionSelected: ,
      padding: EdgeInsets.zero,
      // decoration: state.decorate(decoration, isEnabled: isEnabled),
      surfaceTintColor: theme.canvasColor,
      itemBuilder: (context) => itemsBuilder(context, viewValue),
      icon: icon,
      child: builder != null ? buildChild(builder!) : null,
    );

    // final button = PopupMenuButton<T>(
    //   onSelected: changeValue,
    //   enabled: isEnabled,
    //   constraints: constraints,
    //   // focusNode: state.focusNode,
    //   // onOptionSelected: ,
    //   padding: padding,
    //   // decoration: state.decorate(decoration, isEnabled: isEnabled),
    //   itemBuilder: (context) => itemBuilder(context, state.value),
    //   child: builder?.call(context, state.value),
    // );
    // return ConstrainedBox(
    //   constraints: constraints,
    //   child: InputDecorator(
    //     decoration: decoration,
    //     child: button,
    //   ),
    // );
  }
}
