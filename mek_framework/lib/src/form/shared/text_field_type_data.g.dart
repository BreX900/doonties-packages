// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_field_type_data.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$TextFieldTypeData {
  TextFieldTypeData get _self => this as TextFieldTypeData;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextFieldTypeData &&
          runtimeType == other.runtimeType &&
          _self.keyboardType == other.keyboardType &&
          $listEquality.equals(_self.inputFormatters, other.inputFormatters) &&
          _self.readOnly == other.readOnly &&
          _self.obscureText == other.obscureText &&
          _self.enableSuggestions == other.enableSuggestions &&
          _self.autocorrect == other.autocorrect;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.keyboardType.hashCode);
    hashCode = $hashCombine(hashCode, $listEquality.hash(_self.inputFormatters));
    hashCode = $hashCombine(hashCode, _self.readOnly.hashCode);
    hashCode = $hashCombine(hashCode, _self.obscureText.hashCode);
    hashCode = $hashCombine(hashCode, _self.enableSuggestions.hashCode);
    hashCode = $hashCombine(hashCode, _self.autocorrect.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('TextFieldTypeData')
        ..add('keyboardType', _self.keyboardType)
        ..add('inputFormatters', _self.inputFormatters)
        ..add('readOnly', _self.readOnly)
        ..add('obscureText', _self.obscureText)
        ..add('enableSuggestions', _self.enableSuggestions)
        ..add('autocorrect', _self.autocorrect))
      .toString();
  TextFieldTypeData copyWith({
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool? readOnly,
    bool? obscureText,
    bool? enableSuggestions,
    bool? autocorrect,
  }) {
    return TextFieldTypeData(
      keyboardType: keyboardType ?? _self.keyboardType,
      inputFormatters: inputFormatters ?? _self.inputFormatters,
      readOnly: readOnly ?? _self.readOnly,
      obscureText: obscureText ?? _self.obscureText,
      enableSuggestions: enableSuggestions ?? _self.enableSuggestions,
      autocorrect: autocorrect ?? _self.autocorrect,
    );
  }
}
