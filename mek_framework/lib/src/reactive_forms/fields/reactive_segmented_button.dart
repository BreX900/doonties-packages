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

class ReactiveSegmentedButton<T> extends ReactiveFormField<Object?, Set<T>> {
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;

  ReactiveSegmentedButton({
    super.key,
    required FormControl<Object?> super.formControl,
    super.valueAccessor,
    required List<ButtonSegment<T>> segments,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    EdgeInsets? expandedInsets,
    ButtonStyle? style,
    bool showSelectedIcon = true,
    Widget? selectedIcon,
  }) : super(
          builder: (field) {
            return SegmentedButton<T>(
              selected: field.value ?? <T>{},
              onSelectionChanged: field.didChange,
              segments: segments,
              multiSelectionEnabled: multiSelectionEnabled,
              emptySelectionAllowed: emptySelectionAllowed,
              expandedInsets: expandedInsets,
              style: style,
              showSelectedIcon: showSelectedIcon,
              selectedIcon: selectedIcon,
            );
          },
        );
  @override
  ReactiveFormFieldState<Object?, Set<T>> createState() => _ReactiveSegmentedButtonState<T>();
}

class _ReactiveSegmentedButtonState<T> extends ReactiveFormFieldState<Object?, Set<T>> {
  @override
  ReactiveSegmentedButton<T> get widget => super.widget as ReactiveSegmentedButton<T>;

  @override
  ControlValueAccessor<Object?, Set<T>> selectValueAccessor() {
    return _X<T>(
      multiSelectionEnabled: widget.multiSelectionEnabled,
      emptySelectionAllowed: widget.emptySelectionAllowed,
    );
  }
}

class _X<T> extends ControlValueAccessor<Object?, Set<T>> {
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;

  _X({
    required this.multiSelectionEnabled,
    required this.emptySelectionAllowed,
  });

  @override
  Set<T>? modelToViewValue(Object? modelValue) {
    if (multiSelectionEnabled) return modelValue as Set<T>?;
    if (emptySelectionAllowed) return modelValue == null ? <T>{} : {modelValue as T};
    return modelValue == null ? <T>{null as T} : <T>{modelValue as T};
  }

  @override
  Object? viewToModelValue(Set<T>? viewValue) {
    if (multiSelectionEnabled) return viewValue;
    return viewValue?.singleOrNull;
  }
}

class Co<T> extends ControlValueAccessor<T, Set<T>> {
  @override
  Set<T>? modelToViewValue(T? modelValue) {
    // TODO: implement modelToViewValue
    throw UnimplementedError();
  }

  @override
  T? viewToModelValue(Set<T>? viewValue) {
    // TODO: implement viewToModelValue
    throw UnimplementedError();
  }
}
