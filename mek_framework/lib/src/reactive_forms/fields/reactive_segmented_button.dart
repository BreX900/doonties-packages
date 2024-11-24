import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveChipsButton<T> extends ReactiveFormField<T, T> {
  ReactiveChipsButton({
    super.key,
    required FormControl<T> super.formControl,
    required List<ButtonSegment<T>> segments,
  }) : super(
          builder: (field) {
            return Row(
              children: segments.map((e) {
                return ActionChip.elevated(
                  // selected: e.value == field.value,
                  // onSelected:
                  //     e.value != field.value && e.enabled ? (_) => field.didChange(e.value) : null,
                  onPressed:
                      e.value != field.value && e.enabled ? () => field.didChange(e.value) : null,
                  tooltip: e.tooltip,
                  avatar: e.icon,
                  label: e.label ?? const SizedBox.shrink(),
                );
              }).toList(),
            );
          },
        );
}

class ReactiveSegmentedButton<T> extends ReactiveFormField<Object?, Set<T?>> {
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;

  ReactiveSegmentedButton({
    Key? key,
    required FormControl<T> formControl,
    // super.valueAccessor,
    required List<ButtonSegment<T?>> segments,
    // super.multiSelectionEnabled = false,
    bool emptySelectionAllowed = false,
    EdgeInsets? expandedInsets,
    ButtonStyle? style,
    bool showSelectedIcon = true,
    Widget? selectedIcon,
  }) : this._(
          key: key,
          formControl: formControl,
          emptySelectionAllowed: emptySelectionAllowed,
          multiSelectionEnabled: false,
          segments: segments,
          expandedInsets: expandedInsets,
          style: style,
          showSelectedIcon: showSelectedIcon,
          selectedIcon: selectedIcon,
        );

  ReactiveSegmentedButton.multi({
    Key? key,
    required FormControl<ISet<T>> formControl,
    // super.valueAccessor,
    required List<ButtonSegment<T?>> segments,
    // super.multiSelectionEnabled = false,
    bool emptySelectionAllowed = false,
    EdgeInsets? expandedInsets,
    ButtonStyle? style,
    bool showSelectedIcon = true,
    Widget? selectedIcon,
  }) : this._(
          key: key,
          formControl: formControl,
          emptySelectionAllowed: emptySelectionAllowed,
          multiSelectionEnabled: true,
          segments: segments,
          expandedInsets: expandedInsets,
          style: style,
          showSelectedIcon: showSelectedIcon,
          selectedIcon: selectedIcon,
        );

  ReactiveSegmentedButton._({
    super.key,
    required FormControl<Object?> super.formControl,
    super.valueAccessor,
    required List<ButtonSegment<T?>> segments,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    EdgeInsets? expandedInsets,
    ButtonStyle? style,
    bool showSelectedIcon = true,
    Widget? selectedIcon,
  }) : super(
          builder: (field) {
            final value = field.value ?? <T?>{};
            final hasNullItem = segments.any((e) => e.value == null);

            return SegmentedButton<T?>(
              selected: value.isEmpty && hasNullItem ? <T?>{null} : value,
              onSelectionChanged: field.didChange,
              segments: segments,
              multiSelectionEnabled: multiSelectionEnabled,
              emptySelectionAllowed: emptySelectionAllowed || (!hasNullItem && value.isEmpty),
              expandedInsets: expandedInsets,
              style: style,
              showSelectedIcon: showSelectedIcon,
              selectedIcon: selectedIcon,
            );
          },
        );

  @override
  ReactiveFormFieldState<Object?, Set<T?>> createState() => _ReactiveSegmentedButtonState<T>();
}

class _ReactiveSegmentedButtonState<T> extends ReactiveFormFieldState<Object?, Set<T?>> {
  @override
  ReactiveSegmentedButton<T> get widget => super.widget as ReactiveSegmentedButton<T>;

  @override
  ControlValueAccessor<Object?, Set<T?>> selectValueAccessor() {
    if (widget.multiSelectionEnabled) {
      return _MultiControlValueAccessor(emptySelectionAllowed: widget.emptySelectionAllowed);
    } else {
      return _SingleControlValueAccessor<T>(emptySelectionAllowed: widget.emptySelectionAllowed);
    }
  }
}

class _MultiControlValueAccessor<T> extends ControlValueAccessor<Set<T>, Set<T>> {
  final bool emptySelectionAllowed;

  _MultiControlValueAccessor({required this.emptySelectionAllowed});

  @override
  Set<T>? modelToViewValue(Set<T>? modelValue) => modelValue;

  @override
  Set<T>? viewToModelValue(Set<T>? viewValue) => viewValue;
}

class _SingleControlValueAccessor<T> extends ControlValueAccessor<T, Set<T>> {
  final bool emptySelectionAllowed;

  _SingleControlValueAccessor({required this.emptySelectionAllowed});

  @override
  Set<T>? modelToViewValue(T? modelValue) => modelValue == null ? <T>{} : <T>{modelValue};

  @override
  T? viewToModelValue(Set<T>? viewValue) => viewValue?.singleOrNull;
}

// class _ControlValueAccessor<T> extends ControlValueAccessor<Object?, Set<T?>> {
//   final bool multiSelectionEnabled;
//   final bool emptySelectionAllowed;
//
//   _ControlValueAccessor({
//     required this.multiSelectionEnabled,
//     required this.emptySelectionAllowed,
//   });
//
//   @override
//   Set<T>? modelToViewValue(Object? modelValue) {
//     if (multiSelectionEnabled) return modelValue as Set<T>?;
//     if (emptySelectionAllowed) return modelValue == null ? <T>{} : {modelValue as T};
//     return modelValue == null ? <T>{null as T} : <T>{modelValue as T};
//   }
//
//   @override
//   Object? viewToModelValue(Set<T?>? viewValue) {
//     if (multiSelectionEnabled) return viewValue;
//     return viewValue?.singleOrNull;
//   }
// }
