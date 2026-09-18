import 'package:reactive_forms/reactive_forms.dart';

abstract final class MekValidators {
  static Validator<dynamic> length(int value) => _LengthValidator(value);

  static Validator<dynamic> greaterThan<T extends Comparable<T>>(T value) =>
      _GreaterValidator(value);

  static Validator<dynamic> lessThan<T extends Comparable<T>>(T value) => _LessValidator(value);
}

abstract final class MekValidationMessages {
  static const String length = 'length';

  static const String greaterThan = 'greaterThan';

  static const String lessThan = 'lessThan';
}

class _LengthValidator extends Validator<dynamic> {
  final int length;

  const _LengthValidator(this.length) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control.value == null) return null;

    List<dynamic>? collection;

    if (control is FormArray<dynamic>) {
      collection = control.value;
    } else if (control is FormGroup) {
      collection = control.value.keys.toList();
    } else if (control is FormControl<Iterable<dynamic>>) {
      collection = control.value?.toList();
    } else if (control is FormControl<String> || control.value is String) {
      collection = control.value.toString().runes.toList();
    }
    if (collection != null && collection.length == length) return null;

    return {
      MekValidationMessages.length: {
        'required': length,
        'actual': collection != null ? collection.length : 0,
      },
    };
  }
}

class _GreaterValidator<T> extends Validator<dynamic> {
  final T limit;

  const _GreaterValidator(this.limit) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control.value == null) return null;
    assert(
      control.value is Comparable<dynamic>,
      'The MinValidator validator is expecting a control of type `Comparable` but received a control of type ${control.value.runtimeType}',
    );

    final comparableValue = control.value as Comparable<dynamic>;
    if (comparableValue.compareTo(limit) > 0) return null;

    return {
      MekValidationMessages.greaterThan: <String, dynamic>{
        'required': limit,
        'actual': control.value,
      },
    };
  }
}

class _LessValidator<T> extends Validator<dynamic> {
  final T limit;

  const _LessValidator(this.limit) : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    if (control.value == null) return null;
    assert(
      control.value is Comparable<dynamic>,
      'The MinValidator validator is expecting a control of type `Comparable` but received a control of type ${control.value.runtimeType}',
    );

    final comparableValue = control.value as Comparable<dynamic>;
    if (comparableValue.compareTo(limit) < 0) return null;

    return {
      MekValidationMessages.lessThan: <String, dynamic>{'required': limit, 'actual': control.value},
    };
  }
}
