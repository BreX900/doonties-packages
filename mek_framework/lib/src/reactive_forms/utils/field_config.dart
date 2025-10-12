import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

sealed class FieldConfigBase<T extends FieldConfigBase<T>> implements ValueListenable<T> {
  final bool? _readOnly;

  bool get readOnly => _readOnly ?? false;

  const FieldConfigBase({required bool? readOnly}) : _readOnly = readOnly;

  FieldConfigBase copyWith({bool? readOnly});

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  T get value;
}

class FieldConfig extends FieldConfigBase<FieldConfig> {
  const FieldConfig({super.readOnly});

  @override
  FieldConfig copyWith({bool? readOnly}) {
    return FieldConfig(readOnly: readOnly ?? _readOnly);
  }

  @override
  FieldConfig get value => this;
}

class TextConfig extends FieldConfigBase<TextConfig> {
  final bool? _obscureText;
  final TextInputType? _keyboardType;
  final List<TextInputFormatter>? _inputFormatters;
  final bool? _enableSuggestions;
  final bool? _autocorrect;

  bool get obscureText => _obscureText ?? false;
  TextInputType? get keyboardType => _keyboardType;
  List<TextInputFormatter>? get inputFormatters => _inputFormatters;
  bool get enableSuggestions => _enableSuggestions ?? true;
  bool get autocorrect => _autocorrect ?? true;

  const TextConfig({
    super.readOnly,
    bool? obscureText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool? enableSuggestions,
    bool? autocorrect,
  }) : _obscureText = obscureText,
       _keyboardType = keyboardType,
       _inputFormatters = inputFormatters,
       _enableSuggestions = enableSuggestions,
       _autocorrect = autocorrect;

  static const TextConfig password = TextConfig(obscureText: true);

  @override
  TextConfig copyWith({bool? readOnly, bool? obscureText}) {
    return TextConfig(
      readOnly: readOnly ?? _readOnly,
      obscureText: obscureText ?? _obscureText,
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      enableSuggestions: _enableSuggestions,
      autocorrect: _autocorrect,
    );
  }

  TextConfig mergeWith({
    bool? readOnly,
    bool? obscureText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool? enableSuggestions,
    bool? autocorrect,
  }) {
    return TextConfig(
      readOnly: _readOnly ?? readOnly,
      obscureText: _obscureText ?? obscureText,
      keyboardType: _keyboardType ?? keyboardType,
      inputFormatters: _inputFormatters ?? inputFormatters,
      enableSuggestions: _enableSuggestions ?? enableSuggestions,
      autocorrect: _autocorrect ?? autocorrect,
    );
  }

  @override
  TextConfig get value => this;
}
