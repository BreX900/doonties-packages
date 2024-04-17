import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:mek/mek.dart';

class FieldMultiDropdown<T> extends FieldBuilder<IList<T>> with InlineFieldBuilder {
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final InputDecoration decoration;
  final ValueChanged<IList<T>>? onChanged;
  final List<PopupMenuEntry<T>> Function(BuildContext context, IList<T> selection) itemsBuilder;
  final Widget Function(BuildContext context, IList<T> selection) builder;

  const FieldMultiDropdown({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.padding,
    this.constraints,
    required this.itemsBuilder,
    required this.builder,
  });

  FieldMultiDropdown.withChip({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.padding,
    this.constraints,
    required List<PopupMenuItem<T>> Function(BuildContext context, IList<T> selection)
        this.itemsBuilder,
  }) : builder = ((context, selection) {
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
                  onDeleted: () => fieldBloc.changeRemovingValue(selected),
                  label: item.child ?? const SizedBox.shrink(),
                );
              }).toList(),
            ),
          );
        });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<IList<T>> state) {
    final theme = Theme.of(context);
    final formTheme = BuiltFormTheme.of(context);
    final isEnabled = state.isEnabled;

    void changeValue(T value) {
      final selection = state.value;
      final newSelection =
          selection.contains(value) ? selection.remove(value) : selection.add(value);
      state.fieldBloc.changeValue(newSelection);
      state.completeEditing();
      onChanged?.call(newSelection);
    }

    final child = InputDecorator(
      isEmpty: state.value.isEmpty,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      child: builder(context, state.value),
    );
    return PopupMenuButton<T>(
      onSelected: changeValue,
      enabled: isEnabled,
      constraints: constraints,
      // focusNode: state.focusNode,
      // onOptionSelected: ,
      padding: EdgeInsets.zero,
      // decoration: state.decorate(decoration, isEnabled: isEnabled),
      surfaceTintColor: theme.canvasColor,
      itemBuilder: (context) => itemsBuilder(context, state.value),
      child: ConstrainedBox(
        constraints: constraints ?? const BoxConstraints(minHeight: kToolbarHeight),
        child: formTheme.wrap(
          padding: padding,
          child: child,
        ),
      ),
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
