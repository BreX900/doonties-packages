import 'package:flutter/material.dart';
import 'package:mek/src/form/fields/field_text.dart';
import 'package:mek/src/form/shared/text_field_type_data.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveTypedTextField<T> extends StatefulWidget {
  final FormControl<T> formControl;
  final ControlValueAccessor<T, String>? valueAccessor;
  final TextFieldType type;
  final bool? readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final InputDecoration decoration;

  const ReactiveTypedTextField({
    super.key,
    required this.formControl,
    this.valueAccessor,
    this.type = TextFieldType.none,
    this.readOnly,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.decoration = const InputDecoration(),
  });

  TextFieldTypeData get _data {
    return TextFieldTypeData(
      // keyboardType: keyboardType,
      readOnly: readOnly,
    );
  }

  @override
  State<ReactiveTypedTextField<T>> createState() => _ReactiveTypedTextFieldState<T>();
}

class _ReactiveTypedTextFieldState<T> extends State<ReactiveTypedTextField<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late TextFieldTypeData _typeData;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _typeData = widget.type.initData(context, widget._data);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;
    final valueAccessor = widget.valueAccessor;
    if (valueAccessor == null) return;

    _controller.text = valueAccessor.modelToViewValue(widget.formControl.value) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final typeData = widget.type.buildData(context, _typeData);
    final decoration = widget.type.buildDecoration(context, widget.decoration);

    final child = ReactiveTextField(
      formControl: widget.formControl,
      valueAccessor: widget.valueAccessor,
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      decoration: decoration,
      readOnly: typeData.readOnly ?? false,
      obscureText: typeData.obscureText,
      enableSuggestions: typeData.enableSuggestions,
      autocorrect: typeData.autocorrect,
      keyboardType: typeData.keyboardType,
      inputFormatters: typeData.inputFormatters,
    );
    return TextFieldScope(
      decoration: decoration,
      typeData: typeData,
      changeData: (data) => setState(() {
        _typeData = data;
      }),
      child: child,
    );
  }
}
