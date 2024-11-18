import 'package:flutter/services.dart';
import 'package:mek_data_class/mek_data_class.dart';

part 'text_field_type_data.g.dart';

@DataClass(copyable: true)
class TextFieldTypeData with _$TextFieldTypeData {
  final TextInputType? keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool? readOnly;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;

  const TextFieldTypeData({
    this.keyboardType,
    this.inputFormatters = const [],
    this.readOnly,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
  });
}
