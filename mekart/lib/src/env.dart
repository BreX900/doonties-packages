// ignore_for_file: omit_local_variable_types, avoid_print

import 'dart:convert';

// Picked from:
// - https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/runner/flutter_command.dart#L1559
// - https://github.com/flutter/flutter/blob/master/packages/flutter_tools/lib/src/runner/flutter_command.dart#L40

/// Converts an .env file string to its equivalent JSON string.
///
/// For example, the .env file string
///   key=value # comment
///   complexKey="foo#bar=baz"
/// would be converted to a JSON string equivalent to:
///   {
///     "key": "value",
///     "complexKey": "foo#bar=baz"
///   }
///
/// Multiline values are not supported.
String convertEnvFileToJsonRaw(String configRaw) {
  final List<String> lines = configRaw
      .split('\n')
      .map((String line) => line.trim())
      .where((String line) => line.isNotEmpty)
      .where((String line) => !line.startsWith('#')) // Remove comment lines.
      .toList();

  final Map<String, String> propertyMap = <String, String>{};
  for (final String line in lines) {
    final MapEntry<String, String> property = _parseProperty(line);
    propertyMap[property.key] = property.value;
  }

  return jsonEncode(propertyMap);
}

/// Parse a property line from an env file.
/// Supposed property structure should be:
///   key=value
///
/// Where: key is a string without spaces and value is a string.
/// Value can also contain '=' char.
///
/// Returns a record of key and value as strings.
MapEntry<String, String> _parseProperty(String line) {
  if (DotEnvRegex.multiLineBlock.hasMatch(line)) {
    throw FormatException('Multi-line value is not supported', line);
  }

  final Match? keyValueMatch = DotEnvRegex.keyValue.firstMatch(line);
  if (keyValueMatch == null) {
    throw FormatException(
        'Unable to parse file provided for --define-from-file.\n'
        'Invalid property line',
        line);
  }

  final String key = keyValueMatch.group(1)!;
  final String value = keyValueMatch.group(2) ?? '';

  // Remove wrapping quotes and trailing line comment.
  final Match? doubleQuotedValueMatch = DotEnvRegex.doubleQuotedValue.firstMatch(value);
  if (doubleQuotedValueMatch != null) {
    return MapEntry<String, String>(key, doubleQuotedValueMatch.group(1)!);
  }

  final Match? singleQuotedValueMatch = DotEnvRegex.singleQuotedValue.firstMatch(value);
  if (singleQuotedValueMatch != null) {
    return MapEntry<String, String>(key, singleQuotedValueMatch.group(1)!);
  }

  final Match? backQuotedValueMatch = DotEnvRegex.backQuotedValue.firstMatch(value);
  if (backQuotedValueMatch != null) {
    return MapEntry<String, String>(key, backQuotedValueMatch.group(1)!);
  }

  final Match? unquotedValueMatch = DotEnvRegex.unquotedValue.firstMatch(value);
  if (unquotedValueMatch != null) {
    return MapEntry<String, String>(key, unquotedValueMatch.group(1)!);
  }

  return MapEntry<String, String>(key, value);
}

abstract class DotEnvRegex {
  // Dot env multi-line block value regex
  static final RegExp multiLineBlock = RegExp(r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*"""\s*(.*)$');

  // Dot env full line value regex (eg FOO=bar)
  // Entire line will be matched including key and value
  static final RegExp keyValue = RegExp(r'^\s*([a-zA-Z_]+[a-zA-Z0-9_]*)\s*=\s*(.*)?$');

  // Dot env value wrapped in double quotes regex (eg FOO="bar")
  // Value between double quotes will be matched (eg only bar in "bar")
  static final RegExp doubleQuotedValue = RegExp(r'^"(.*)"\s*(\#\s*.*)?$');

  // Dot env value wrapped in single quotes regex (eg FOO='bar')
  // Value between single quotes will be matched (eg only bar in 'bar')
  static final RegExp singleQuotedValue = RegExp(r"^'(.*)'\s*(\#\s*.*)?$");

  // Dot env value wrapped in back quotes regex (eg FOO=`bar`)
  // Value between back quotes will be matched (eg only bar in `bar`)
  static final RegExp backQuotedValue = RegExp(r'^`(.*)`\s*(\#\s*.*)?$');

  // Dot env value without quotes regex (eg FOO=bar)
  // Value without quotes will be matched (eg full value after the equals sign)
  static final RegExp unquotedValue = RegExp(r'^([^#\n\s]*)\s*(?:\s*#\s*(.*))?$');
}
