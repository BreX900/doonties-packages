import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/reactive_forms/text_field_variant.dart';
import 'package:mek/src/reactive_forms/utils/field_config.dart';
import 'package:mek/src/riverpod/adapters/value_listenable_provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveTypedTextField<T> extends ConsumerStatefulWidget {
  final FormControl<T> formControl;
  final ControlValueAccessor<T, String>? valueAccessor;
  final TextFieldVariant variant;
  final ValueListenable<TextConfig> config;
  final bool? readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final InputDecoration decoration;
  final ReactiveFormFieldCallback<T>? onTap;
  final ReactiveFormFieldCallback<T>? onEditingComplete;
  final ReactiveFormFieldCallback<T>? onSubmitted;
  final ReactiveFormFieldCallback<T>? onChanged;

  const ReactiveTypedTextField({
    super.key,
    required this.formControl,
    this.valueAccessor,
    this.variant = TextFieldVariant.none,
    this.config = const TextConfig(),
    this.readOnly,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.decoration = const InputDecoration(),
    this.onTap,
    this.onEditingComplete,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  ConsumerState<ReactiveTypedTextField<T>> createState() => _ReactiveTypedTextFieldState<T>();
}

class _ReactiveTypedTextFieldState<T> extends ConsumerState<ReactiveTypedTextField<T>> {
  final _fieldStateKey = GlobalKey<ReactiveFormFieldState<T, String>>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) return;

    final valueAccessor = _fieldStateKey.currentState!.valueAccessor;
    final text = valueAccessor.modelToViewValue(widget.formControl.value) ?? '';
    final value = _controller.value;
    if (value.text == text) return;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: min(value.selection.baseOffset, text.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rawConfig = ref.watch(widget.config.provider);
    final config = widget.variant.buildConfig(context, rawConfig);

    return ReactiveTextField<T>(
      key: _fieldStateKey,
      formControl: widget.formControl,
      valueAccessor: widget.valueAccessor,
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      decoration: widget.decoration,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      // config
      readOnly: config.readOnly,
      obscureText: config.obscureText,
      enableSuggestions: config.enableSuggestions,
      autocorrect: config.autocorrect,
      keyboardType: config.keyboardType,
      inputFormatters: config.inputFormatters,
    );
  }
}
