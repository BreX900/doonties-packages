import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveDropdownMenuField<T> extends ReactiveFocusableFormField<T, T> {
  final List<DropdownMenuEntry<T>> entries;

  ReactiveDropdownMenuField({
    super.key,
    required FormControl<T> super.formControl,
    EdgeInsetsGeometry? expandedInsets,
    InputDecorationThemeData? inputDecorationTheme,
    Widget? label,
    required this.entries,
  }) : super(
         builder: (field) {
           field as _ReactiveFormFieldState<T>;

           return DropdownMenu(
             controller: field._controller,
             enableFilter: true,
             focusNode: field.focusNode,
             dropdownMenuEntries: entries,
             initialSelection: field.value,
             label: label,
             expandedInsets: expandedInsets,
             errorText: field.errorText,
             enabled: field.control.enabled,
             onSelected: field.didChange,
             inputDecorationTheme: inputDecorationTheme,
           );
         },
       );

  @override
  ReactiveFormFieldState<T, T> createState() => _ReactiveFormFieldState();
}

class _ReactiveFormFieldState<T> extends ReactiveFocusableFormFieldState<T, T> {
  final _controller = TextEditingController();

  @override
  ReactiveDropdownMenuField<T> get widget => super.widget as ReactiveDropdownMenuField<T>;

  @override
  void didUpdateWidget(covariant ReactiveDropdownMenuField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formControl != oldWidget.formControl) {
      if (widget.formControl?.value == null) {
        final entry = widget.entries.firstWhereOrNull((e) => e.value == value);
        _controller.text = entry?.label ?? '';
      }
    }
    final nextEntry = widget.entries.firstWhereOrNull((e) => e.value == value);
    final oldEntry = oldWidget.entries.firstWhereOrNull((e) => e.value == value);
    if (nextEntry?.value != oldEntry?.value || nextEntry?.label != oldEntry?.label) {
      _controller.text = nextEntry?.label ?? '';
    }
  }

  @override
  void onControlValueChanged(Object? value) {
    if (value == null) _controller.text = '';
    super.onControlValueChanged(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
