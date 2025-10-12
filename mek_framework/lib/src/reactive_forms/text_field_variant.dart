import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mek/src/reactive_forms/utils/field_config.dart';

abstract class TextFieldVariant {
  const TextFieldVariant();

  static const TextFieldVariant none = _NoneTextFieldVariant();

  const factory TextFieldVariant.integer({bool signed}) = _NumericTextFieldVariant.integer;
  const factory TextFieldVariant.decimal({bool signed}) = _NumericTextFieldVariant.decimal;
  const factory TextFieldVariant.email() = _EmailTextFieldVariant;
  const factory TextFieldVariant.password() = _PasswordTextFieldVariant;
  const factory TextFieldVariant.secret() = _SecretTextFieldType;
  const factory TextFieldVariant.phoneNumber() = _PhoneNumberTextFieldVariant;

  TextConfig buildConfig(BuildContext context, TextConfig data) => data;
}

class _NoneTextFieldVariant extends TextFieldVariant {
  const _NoneTextFieldVariant();
}

class _NumericTextFieldVariant extends TextFieldVariant {
  final bool signed;
  final bool decimal;

  const _NumericTextFieldVariant.integer({this.signed = false}) : decimal = false;

  const _NumericTextFieldVariant.decimal({this.signed = false}) : decimal = true;

  @override
  TextConfig buildConfig(BuildContext context, TextConfig data) {
    final locale = Localizations.localeOf(context);

    return data.mergeWith(
      keyboardType: TextInputType.numberWithOptions(signed: signed, decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'(\d|[,.])*')),
        _NumericTextInputFormatter(
          languageCode: locale.languageCode,
          signed: signed,
          decimal: decimal,
        ),
      ],
    );
  }
}

class _NumericTextInputFormatter implements TextInputFormatter {
  final String languageCode;
  final bool signed;
  final bool decimal;

  const _NumericTextInputFormatter({
    required this.languageCode,
    this.signed = false,
    this.decimal = false,
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final format = NumberFormat.decimalPattern(languageCode);
    final symbols = format.symbols;
    final separatorOffset = newValue.text.indexOf(symbols.DECIMAL_SEP);

    var whole = separatorOffset != -1 ? newValue.text.substring(0, separatorOffset) : newValue.text;
    whole = whole.replaceAll(symbols.GROUP_SEP, '');

    final buffer = [whole.substring(max(whole.length - 3, 0))];
    for (var i = whole.length - 3; i > 0; i -= 3) {
      buffer.insert(0, symbols.GROUP_SEP);
      buffer.insert(0, whole.substring(max(i - 3, 0), i));
    }

    if (decimal && separatorOffset != -1) {
      buffer.add(symbols.DECIMAL_SEP);

      var dividend = separatorOffset != -1 ? newValue.text.substring(separatorOffset + 1) : '';
      dividend = dividend.replaceAll(symbols.GROUP_SEP, '');

      buffer.add(dividend);
    }

    final text = buffer.join();
    return TextEditingValue(
      text: text,
      selection: text.length == newValue.text.length
          ? newValue.selection
          : text.length - 1 == newValue.text.length
          ? TextSelection.collapsed(offset: newValue.selection.baseOffset + 1)
          : text.length + 1 == newValue.text.length
          ? TextSelection.collapsed(offset: newValue.selection.baseOffset - 1)
          : TextSelection.collapsed(offset: text.length),
    );
  }
}

class _EmailTextFieldVariant extends TextFieldVariant {
  const _EmailTextFieldVariant();

  @override
  TextConfig buildConfig(BuildContext context, TextConfig data) {
    return data.mergeWith(
      inputFormatters: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.deny(' '),
      ],
    );
  }
}

class _PasswordTextFieldVariant extends TextFieldVariant {
  const _PasswordTextFieldVariant();

  @override
  TextConfig buildConfig(BuildContext context, TextConfig data) {
    return data.mergeWith(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.deny(' '),
      ],
    );
  }
}

class _SecretTextFieldType extends TextFieldVariant {
  const _SecretTextFieldType();

  @override
  TextConfig buildConfig(BuildContext context, TextConfig data) {
    return data.mergeWith(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.deny(' '),
      ],
    );
  }
}

class _PhoneNumberTextFieldVariant extends TextFieldVariant {
  const _PhoneNumberTextFieldVariant();

  @override
  TextConfig buildConfig(BuildContext context, TextConfig data) {
    return data.mergeWith(
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+\d ]'))],
    );
  }
}
