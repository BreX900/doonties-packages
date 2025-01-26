import 'package:mek/src/form/validation/validation.dart';
import 'package:mek/src/form/validation/validation_errors.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract final class ValidationCodes {
  static const String invalid = 'invalid';
  static const String required = 'required';
  static const String comparable = 'comparable';
  static const String text = 'text';
  static const String email = 'email';
  static const String password = 'password';
  static const String options = 'options';

  static const List<String> values = [required, comparable, text, email, password, options];
}

abstract final class ValidatorsTyped {
  static Validator<T> from<T>(Object? Function(AbstractControl<T> control) validator,
      {String code = ValidationCodes.invalid}) {
    return _ReactiveErrorAdapter(InvalidValidationError(code: code), (control) {
      final error = validator(control);
      if (error == null) return null;
      return {'': error};
    });
  }

  static Validator<T> required<T>({String code = ValidationCodes.required}) {
    return _ReactiveErrorAdapter(RequiredValidationError(code: code), const RequiredValidator());
  }

  static Validator<T> comparable<T extends Comparable<Object>>({
    String code = ValidationCodes.comparable,
    T? lessThan,
    T? lessOrEqualThan,
    T? greaterOrEqualThan,
    T? greaterThan,
  }) {
    return _ValidationAdapter(NumberValidation(
      errorCode: code,
      lessThan: lessThan,
      lessOrEqualThan: lessOrEqualThan,
      greaterOrEqualThan: greaterOrEqualThan,
      greaterThan: greaterThan,
    ));
  }

  static Validator<String> text({
    String code = ValidationCodes.text,
    int? minLength,
    int? maxLength,
    RegExp? match,
    RegExp? notMatch,
  }) {
    return _ValidationAdapter(TextValidation(
      errorCode: code,
      minLength: minLength,
      maxLength: maxLength,
      match: match,
      notMatch: notMatch,
    ));
  }

  static Validator<R> iterable<R extends Iterable>({
    String code = ValidationCodes.options,
    Set<int>? lengths,
    int? minLength,
    int? maxLength,
    R? whereIn,
    R? whereNotIn,
  }) {
    return _ReactiveTypeAdapter(_ValidationAdapter(OptionsValidation(
      errorCode: code,
      lengths: lengths,
      minLength: minLength,
      maxLength: maxLength,
      whereIn: whereIn?.toList(),
      whereNotIn: whereNotIn?.toList(),
    )));
  }

  static Validator<String> email({String message = ValidationCodes.email}) {
    return _ReactiveErrorAdapter(InvalidValidationError(code: message), const EmailValidator());
  }

  static Validator<String> password() {
    return composeOR([
      text(code: ValidationCodes.password, minLength: 8),
      text(
        code: ValidationCodes.password,
        match: RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*^[a-zA-Z])([a-zA-Z\d]|[^a-zA-Z\d]){8,14}$'),
      )
    ]);
  }

  static Validator<T> compose<T>(List<Validator<T>> validators) =>
      _ReactiveTypeAdapter(Validators.compose(validators));

  static Validator<T> composeOR<T>(List<Validator<T>> validators) =>
      _ReactiveTypeAdapter(Validators.composeOR(validators));
}

class _ReactiveTypeAdapter<T> extends Validator<T> {
  final Validator<dynamic> validator;

  const _ReactiveTypeAdapter(this.validator);

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) => validator.validate(control);
}

class _ValidationAdapter<T> extends Validator<T> {
  final Validation<T> validation;

  _ValidationAdapter(this.validation);

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) {
    final value = control.value;
    if (value == null) return null;

    final error = validation(value) as ValidationError?;
    if (error == null) return null;

    return {error.code!: error};
  }
}

class _ReactiveErrorAdapter<T> extends Validator<T> {
  final ValidationError error;
  final Map<String, dynamic>? Function(AbstractControl<T> control) validator;

  _ReactiveErrorAdapter(this.error, this.validator) : assert(error.code != null);

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) {
    final errors = validator(control);
    if (errors == null) return null;

    return {error.code!: errors.values.single};
  }
}

// class _ValidatorTyped<T> extends Validator<T> {
//   final String? message;
//   final List<Validator<dynamic>> validators;
//
//   const _ValidatorTyped(this.message, this.validators);
//
//   @override
//   Map<String, dynamic>? validate(AbstractControl<T> control) {
//     final errors = _validate(control);
//
//     final message = this.message;
//     if (message == null) return errors;
//     if (errors == null || errors.isEmpty) return errors;
//
//     return {message: errors.values.single};
//   }
//
//   Map<String, dynamic>? _validate(AbstractControl<dynamic> control) {
//     for (final validator in validators) {
//       final error = validator.validate(control);
//       if (error != null) return error;
//     }
//     return null;
//   }
// }

// class _ComparableValidator<T extends Comparable<Object>> extends Validator<T> {
//   final T? lessThan;
//   final T? greaterThan;
//   final String? message;
//
//   const _ComparableValidator({
//     required this.lessThan,
//     required this.greaterThan,
//     required this.message,
//   }) : assert(lessThan != null || greaterThan != null);
//
//   @override
//   Map<String, Object>? validate(AbstractControl<T?> control) {
//     final value = control.value;
//     if (value == null) return null;
//
//     final lessThan = this.lessThan;
//     if (lessThan != null) {
//       if (value.compareTo(lessThan) < 0) return null;
//
//       return {
//         message ?? ValidationCodes.lessThan: NumberValidationError<T>(
//           code: message ?? ValidationCodes.lessThan,
//           lessThan: lessThan,
//         ),
//       };
//     }
//     final greaterThan = this.greaterThan;
//     if (greaterThan != null) {
//       if (value.compareTo(greaterThan) > 0) return null;
//
//       return {
//         message ?? ValidationCodes.greaterThan: NumberValidationError(
//           code: message ?? ValidationCodes.lessThan,
//           greaterThan: greaterThan,
//         ),
//       };
//     }
//     return null;
//   }
// }
