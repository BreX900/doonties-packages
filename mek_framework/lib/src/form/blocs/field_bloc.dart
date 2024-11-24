import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/core/_param.dart';
import 'package:mek/src/form/validation/validation.dart';
import 'package:mek_data_class/mek_data_class.dart';

part 'field_bloc.g.dart';

typedef AsyncValidator<T> = Future<Object?> Function(T value);

enum FieldBlocStatus { disabled, pending, invalid, valid }

extension FieldBlocStatusExtensions on FieldBlocStatus {
  bool get isDisabled => this == FieldBlocStatus.disabled;
  bool get isInvalid => this == FieldBlocStatus.invalid;
  bool get isPending => this == FieldBlocStatus.pending;
  bool get isValid => this == FieldBlocStatus.valid;
}

abstract class FieldBlocStateBase<TValue> {
  bool get isEnabled;
  bool get isValidating;
  bool get isDirty;
  TValue get value;
  bool get hasUpdatedValue;
  bool get hasInitialValue;
  Object? get error;

  const FieldBlocStateBase();

  bool get hasError => error != null;

  FieldBlocStatus get status {
    if (!isEnabled) return FieldBlocStatus.disabled;
    if (isValidating) return FieldBlocStatus.pending;
    return hasError ? FieldBlocStatus.invalid : FieldBlocStatus.valid;
  }
}

abstract class FieldBlocBase<TState extends FieldBlocStateBase<TValue>, TValue>
    extends Cubit<TState> {
  FieldBlocBase(super.initialState);

  void changeValue(TValue value);

  void updateValue(TValue value);

  void updateInitialValue(TValue value);

  void markAsUpdated() => updateValue(state.value);

  void markAsChanged() => changeValue(state.value);

  void markStateAs({bool? enabled, bool? touched});

  void enable() => markStateAs(enabled: true);

  void disable() => markStateAs(enabled: false);

  void touch() => markStateAs(touched: true);

  void clear({bool shouldUpdate = true});

  FutureOr<bool> validate();
}

typedef FieldBlocRule<TValue> = FieldBlocBase<FieldBlocStateBase<TValue>, TValue>;

@DataClass(changeable: true)
class FieldBlocState<TValue> extends FieldBlocStateBase<TValue> with _$FieldBlocState<TValue> {
  @override
  final bool isEnabled;
  @override
  final bool isValidating;
  @override
  final bool isDirty;
  final TValue initialValue;
  final TValue updatedValue;
  @override
  final TValue value;
  @override
  final Object? error;

  const FieldBlocState({
    required this.isEnabled,
    required this.isValidating,
    required this.isDirty,
    required this.initialValue,
    required this.updatedValue,
    required this.value,
    required this.error,
  });

  @override
  bool get hasUpdatedValue => updatedValue == value;
  @override
  bool get hasInitialValue => initialValue == value;
}

class FieldBloc<TValue> extends FieldBlocBase<FieldBlocState<TValue>, TValue> {
  ValidatorCallback<TValue>? _validator;
  AsyncValidator<TValue>? _asyncValidator;
  final Duration debounceTime;

  @Deprecated('In favour of reactive_forms')
  FieldBloc({
    bool isEnabled = true,
    bool isDirty = false,
    required TValue initialValue,
    ValidatorCallback<TValue>? validator,
    AsyncValidator<TValue>? asyncValidator,
    this.debounceTime = const Duration(seconds: 3),
  })  : _validator = validator,
        _asyncValidator = asyncValidator,
        super(() {
          final error = validator?.call(initialValue);
          return FieldBlocState(
            isEnabled: isEnabled,
            isValidating: error == null && asyncValidator != null,
            isDirty: isDirty,
            initialValue: initialValue,
            updatedValue: initialValue,
            value: initialValue,
            error: error,
          );
        }()) {
    _maybeValidateAsync($value: state.value, error: state.error);
  }

  @override
  void changeValue(TValue value) {
    final error = _validate(value: value);
    final isValidating = _maybeValidateAsync($value: value, error: error);

    emit(state.change((c) => c
      ..value = value
      ..isDirty = true
      ..error = error
      ..isValidating = isValidating));
  }

  @override
  void updateValue(TValue? value) {
    final effectiveValue = value is! TValue ? state.initialValue : value;

    final error = _validate(value: effectiveValue);
    final isValidating = _maybeValidateAsync($value: effectiveValue, error: error);

    emit(state.change((c) => c
      ..value = effectiveValue
      ..updatedValue = effectiveValue
      ..isDirty = false
      ..error = error
      ..isValidating = isValidating));
  }

  @override
  void updateInitialValue(TValue value) {
    final error = _validate(value: value);
    final isValidating = _maybeValidateAsync($value: value, error: error);

    emit(state.change((c) => c
      ..initialValue = value
      ..isDirty = false
      ..error = error
      ..isValidating = isValidating));
  }

  void updateError(Object error) {
    _cancelValidation();
    emit(state.change((c) => c
      ..isDirty = true
      ..error = error
      ..isValidating = false));
  }

  void updateValidator(ValidatorCallback<TValue> validator) {
    _validator = validator;

    final error = _validate(value: state.value);
    final isValidating = _maybeValidateAsync($value: state.value, error: error);

    emit(state.change((c) => c
      ..error = error
      ..isValidating = isValidating));
  }

  void updateAsyncValidator(AsyncValidator<TValue> validator) {
    _asyncValidator = validator;

    final error = _validate(value: state.value);
    final isValidating = _maybeValidateAsync($value: state.value, error: error);

    emit(state.change((c) => c
      ..error = error
      ..isValidating = isValidating));
  }

  @override
  void markStateAs({bool? enabled, bool? touched}) {
    emit(state.change((c) => c
      ..isDirty = touched ?? c.isDirty
      ..isEnabled = enabled ?? c.isEnabled));
  }

  @override
  void clear({bool shouldUpdate = true}) {
    if (shouldUpdate) {
      updateValue(state.initialValue);
    } else {
      changeValue(state.initialValue);
    }
  }

  @override
  FutureOr<bool> validate() {
    touch();
    if (_validation != null) return _validation!.future;
    return state.error == null;
  }

  Object? _validate({required TValue value}) => _validator?.call(value);

  Completer<bool>? _validation;
  AsyncValidator<TValue>? _validationValidator;
  Param<TValue>? _validationValue;

  bool _maybeValidateAsync({required Object? error, required TValue $value}) {
    final value = Param($value);
    final validator = _asyncValidator;

    if (error != null) return false;
    if (validator == null) return false;
    if (validator == _validationValidator && _validationValue == value) {
      return _validation != null;
    }

    _validation ??= Completer();
    unawaited(_validateAsync(
      _validationValidator = validator,
      _validationValue = value,
    ));

    return true;
  }

  Future<void> _validateAsync(AsyncValidator<TValue> validator, Param<TValue> param) async {
    bool isDiscarded() => _validationValidator != validator || !identical(_validationValue, param);

    if (debounceTime > Duration.zero) {
      await Future<void>.delayed(debounceTime);
      if (isDiscarded()) return;
    }

    final error = await validator(param.value);
    if (isDiscarded()) return;

    emit(state.change((c) => c
      ..error = error
      ..isValidating = false));
    _validation!.complete(error == null);
    _validation = null;
  }

  void _cancelValidation() => _validationValue = null;
}
