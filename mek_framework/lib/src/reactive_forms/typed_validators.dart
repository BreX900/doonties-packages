import 'package:reactive_forms/reactive_forms.dart';

class TypedFormControl<T> extends FormControl<T> {
  TypedFormControl({
    super.value,
    List<Validator<T>> super.validators = const [],
  });
}

abstract final class TypedValidationMessage {
  static const String greaterThan = 'greaterThan';

  static const String lessThan = 'lessThan';
}

abstract final class TypedValidators {
  static Validator<T> required<T>() => _TypedValidator(Validators.required);

  static Validator<T> greaterThan<T extends Comparable>(T value) => _GreaterThanValidator(value);

  static Validator<T> lessThan<T extends Comparable>(T value) => _LessThanValidator(value);
}

class _TypedValidator<T> extends Validator<T> {
  final Validator<dynamic> validator;

  _TypedValidator(this.validator);

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) => validator(control);
}

class _GreaterThanValidator<T extends Comparable> extends Validator<T> {
  final T value;

  const _GreaterThanValidator(this.value);

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) {
    final value = control.value;
    if (value == null) return null;

    if (value.compareTo(this.value) > 0) return null;

    return {
      TypedValidationMessage.greaterThan: <String, dynamic>{
        'greaterThan': value,
        'actual': control.value,
      },
    };
  }
}

class _LessThanValidator<T extends Comparable> extends Validator<T> {
  final T value;

  const _LessThanValidator(this.value);

  @override
  Map<String, dynamic>? validate(AbstractControl<T> control) {
    final value = control.value;
    if (value == null) return null;

    if (value.compareTo(this.value) < 0) return null;

    return {
      TypedValidationMessage.lessThan: <String, dynamic>{
        'lessThan': value,
        'actual': control.value,
      },
    };
  }
}
