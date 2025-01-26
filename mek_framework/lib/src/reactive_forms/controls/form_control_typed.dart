import 'package:reactive_forms/reactive_forms.dart';

class FormControlTyped<T extends Object> extends FormControl<T> {
  final T initialValue;

  FormControlTyped({
    required this.initialValue,
    List<Validator<T>> super.validators = const [],
    T? value,
    super.disabled,
  }) : super(value: value ?? initialValue);

  @override
  late final Stream<T> valueChanges = super.valueChanges.cast<T>();

  @override
  T get value => super.value ?? initialValue;

  bool get isValueInitial => value == initialValue;

  @override
  T? reduceValue() => super.reduceValue() ?? initialValue;
}

class FormControlTypedOptional<T extends Object> extends FormControl<T> {
  final T? initialValue;

  FormControlTypedOptional({
    this.initialValue,
    List<Validator<T>> super.validators = const [],
    T? value,
  }) : super(value: value ?? initialValue);

  @override
  T? get value => super.value ?? initialValue;

  bool get hasInitialValue => value == initialValue;

  @override
  T? reduceValue() => super.reduceValue() ?? initialValue;
}

extension AbstractControlX on AbstractControl {
  bool get isValueInitial {
    final control = this;
    return switch (control) {
      FormControlTyped() => control.isValueInitial,
      FormControlTypedOptional() => control.hasInitialValue,
      // _FormControlTyped() => control.hasInitialValue,
      FormArray() => control.controls.every((e) => e.isValueInitial),
      FormGroup() => control.controls.values.every((e) => e.isValueInitial),
      _ => value == null,
    };
  }
}

// class FormControlTyped<T extends Object> extends FormControl<T> {
//   final T initialValue;
//
//   FormControlTyped({
//     required this.initialValue,
//     List<Validator<T>> super.validators = const [],
//     T? value,
//   }) : super(value: value ?? initialValue);
//
//   @override
//   T get value => super.value ?? initialValue;
//
//   bool get hasInitialValue => value == initialValue;
//
//   static FormControl<T> empty<T extends Object>({
//     T? initialValue,
//     T? value,
//     List<Validator<T>> validators = const [],
//   }) {
//     return _FormControlTyped(
//       initialValue: initialValue,
//       value: value,
//       validators: validators,
//     );
//   }
//
//   @override
//   T? reduceValue() => super.reduceValue() ?? initialValue;
// }
//
// class _FormControlTyped<T extends Object> extends FormControl<T> {
//   final T? initialValue;
//
//   _FormControlTyped({
//     this.initialValue,
//     List<Validator<T>> super.validators = const [],
//     T? value,
//   }) : super(value: value ?? initialValue);
//
//   bool get hasInitialValue => value == initialValue;
//
//   @override
//   T? reduceValue() => super.reduceValue() ?? initialValue;
// }
