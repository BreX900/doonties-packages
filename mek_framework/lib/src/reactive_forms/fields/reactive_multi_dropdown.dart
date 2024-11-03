import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';
import 'package:reactive_forms/reactive_forms.dart';

typedef ReactivePopupMenuButtonState<T> = ReactiveFormFieldState<ISet<T>, ISet<T>>;

class ReactivePopupMenuButton<T> extends ReactiveFormField<ISet<T>, ISet<T>> {
  ReactivePopupMenuButton({
    super.key,
    required FormControl<ISet<T>> super.formControl,
    EdgeInsetsGeometry? padding,
    BoxConstraints? constraints,
    InputDecoration decoration = const InputDecoration(),
    ValueChanged<ISet<T>>? onChanged,
    required List<PopupMenuEntry<T>> Function(ReactivePopupMenuButtonState<T> field) itemBuilder,
    Widget Function(ReactivePopupMenuButtonState<T> field)? builder,
    Widget? icon,
  }) : super(
          builder: (field) {
            final theme = Theme.of(field.context);
            final formTheme = BuiltFormTheme.of(field.context);
            final isEnabled = field.control.enabled;

            final values = field.value ?? ISet<T>.empty();

            void changeValue(T value) {
              final newValues = values.contains(value) ? values.remove(value) : values.add(value);
              field.didChange(newValues);
              onChanged?.call(newValues);
            }

            Widget buildChild(Widget Function(ReactivePopupMenuButtonState<T> field) builder) {
              final child = InputDecorator(
                isEmpty: values.isEmpty,
                decoration: decoration.copyWith(errorText: field.errorText),
                child: builder(field),
              );
              return ConstrainedBox(
                constraints: constraints ?? const BoxConstraints(minHeight: kToolbarHeight),
                child: formTheme.wrap(
                  padding: padding,
                  child: child,
                ),
              );
            }

            return PopupMenuButton<T>(
              onSelected: changeValue,
              enabled: isEnabled,
              constraints: constraints,
              // onOptionSelected: ,
              padding: EdgeInsets.zero,
              // decoration: state.decorate(decoration, isEnabled: isEnabled),
              surfaceTintColor: theme.canvasColor,
              itemBuilder: (context) => itemBuilder(field),
              icon: icon,
              child: builder != null ? buildChild(builder) : null,
            );
          },
        );

  ReactivePopupMenuButton.withChip({
    Key? key,
    required FormControl<ISet<T>> formControl,
    ValueChanged<ISet<T>>? onChanged,
    InputDecoration decoration = const InputDecoration(),
    required List<PopupMenuItem<T>> Function(ReactivePopupMenuButtonState<T> field) itemBuilder,
  }) : this(
          key: key,
          formControl: formControl,
          decoration: decoration,
          itemBuilder: itemBuilder,
          builder: (field) {
            final items = itemBuilder(field);
            final values = field.value ?? ISet();

            void changeValue(T value) {
              final newValues = values.contains(value) ? values.remove(value) : values.add(value);
              field.didChange(newValues);
              onChanged?.call(newValues);
            }

            return Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: values.map((selected) {
                  final item = items.firstWhere((e) => e.represents(selected));

                  return Chip(
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.only(left: 8.0),
                    onDeleted: () => changeValue(selected),
                    label: item.child ?? const SizedBox.shrink(),
                  );
                }).toList(),
              ),
            );
          },
        );
}