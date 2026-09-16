import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveDropdownMenuField<T> extends ReactiveFocusableFormField<T, T> {
  ReactiveDropdownMenuField({
    super.key,
    required FormControl<T> super.formControl,
    EdgeInsetsGeometry? expandedInsets,
    InputDecorationThemeData? inputDecorationTheme,
    Widget? label,
    required List<DropdownMenuEntry<T>> entries,
  }) : super(
         builder: (field) {
           field as _ReactiveFormFieldState<T, T>;

           return DropdownMenu(
             controller: field._controller,
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

class _ReactiveFormFieldState<T, V> extends ReactiveFocusableFormFieldState<T, V> {
  final _controller = TextEditingController();

  @override
  void didUpdateWidget(covariant ReactiveFormField<T, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.formControl != oldWidget.formControl) {
      if (widget.formControl?.value == null) _controller.text = '';
    }
  }

  @override
  void onControlValueChanged(dynamic value) {
    if (value == null) _controller.text = '';
    super.onControlValueChanged(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
