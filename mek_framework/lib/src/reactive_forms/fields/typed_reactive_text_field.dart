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
  final InputDecoration decoration;

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
    this.decoration = const InputDecoration(),
  });

  @override
  ConsumerState<ReactiveTypedTextField<T>> createState() => _ReactiveTypedTextFieldState<T>();
}

class _ReactiveTypedTextFieldState<T> extends ConsumerState<ReactiveTypedTextField<T>> {
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
    final rawConfig = ref.watch(widget.config.provider);
    final config = widget.variant.buildConfig(context, rawConfig);
    final decoration = widget.variant.buildDecoration(context, widget.decoration);

    return ReactiveTextField(
      formControl: widget.formControl,
      valueAccessor: widget.valueAccessor,
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      decoration: decoration,
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
