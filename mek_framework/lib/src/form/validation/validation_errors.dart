import 'package:mek/src/form/validation/validation.dart';

abstract class ValidationError {
  final Validation<Object?>? validation;
  final String? code;

  const ValidationError(this.validation, this.code);

  static const String codePrefix = 'flutter_ui_bloc:validation_error_code ';
}

class InvalidValidationError extends ValidationError {
  const InvalidValidationError({Validation<Object?>? validation, String? code})
      : super(validation, code);

  static const String intCode = '${ValidationError.codePrefix}Invalid int.';
  static const String doubleCode = '${ValidationError.codePrefix}Invalid double.';
  static const String rationalCode = '${ValidationError.codePrefix}Invalid Rational.';

  @override
  String toString() {
    return '$InvalidValidationError{code: $code}';
  }
}

class RequiredValidationError extends ValidationError {
  const RequiredValidationError({
    Validation<Object?>? validation,
    String? code,
  }) : super(validation, code);

  @override
  String toString() {
    return '$RequiredValidationError{}';
  }
}

class EqualityValidationError<T extends Object> extends ValidationError {
  final T? equals;
  final T? identical;

  const EqualityValidationError({
    Validation<T>? validation,
    String? code,
    this.equals,
    this.identical,
  }) : super(validation, code);

  @override
  String toString() {
    return '$EqualityValidationError{equals:$equals,identical:$identical}';
  }
}

class TextValidationError extends ValidationError {
  final int? minLength;
  final int? maxLength;
  final String? match;
  final String? notMatch;

  static const String emailCode = '${ValidationError.codePrefix}Invalid email.';
  static const String urlCode = '${ValidationError.codePrefix}Invalid url.';

  const TextValidationError({
    Validation<String?>? validation,
    String? code,
    this.minLength,
    this.maxLength,
    this.match,
    this.notMatch,
  }) : super(validation, code);
}

class NumberValidationError<T extends Comparable<Object>> extends ValidationError {
  final T? greaterThan;
  final T? lessThan;
  final T? greaterOrEqualThan;
  final T? lessOrEqualThan;

  const NumberValidationError({
    Validation<Comparable<Object>>? validation,
    String? code,
    this.greaterThan,
    this.lessThan,
    this.greaterOrEqualThan,
    this.lessOrEqualThan,
  }) : super(validation, code);

  @override
  String toString() =>
      '$NumberValidationError{greaterThan:$greaterThan,lessThan:$lessThan,greaterOrEqualThan:$greaterOrEqualThan,lessOrEqualThan:$lessOrEqualThan}';
}

class DateTimeValidationError extends ValidationError {
  final DateTime? before;
  final DateTime? after;

  const DateTimeValidationError({
    Validation<Object?>? validation,
    String? code,
    this.before,
    this.after,
  }) : super(validation, code);

  @override
  String toString() => '$DateTimeValidationError{before:$before,after:$after}';
}

class OptionsValidationError extends ValidationError {
  final int? length;
  final int? minLength;
  final int? maxLength;
  final List<Object?>? whereIn;
  final List<Object?>? whereNotIn;

  const OptionsValidationError({
    Validation<Iterable<Object?>>? validation,
    String? code,
    this.length,
    this.minLength,
    this.maxLength,
    this.whereIn,
    this.whereNotIn,
  }) : super(validation, code);

  @override
  String toString() =>
      '$OptionsValidationError{length:$length,minLength:$minLength,maxLength:$maxLength,whereIn:$whereIn,whereNotIn:$whereNotIn}';
}

class FileValidationError extends ValidationError {
  final List<String>? whereExtensionIn;
  final List<String>? whereExtensionNotIn;

  FileValidationError({
    Validation<Object?>? validation,
    String? code,
    this.whereExtensionIn,
    this.whereExtensionNotIn,
  }) : super(validation, code);

  @override
  String toString() {
    return '$FileValidationError{whereExtensionIn: $whereExtensionIn, whereExtensionNotIn: $whereExtensionNotIn}';
  }
}
