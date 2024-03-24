// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'field_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$FieldBlocState<TValue> {
  FieldBlocState<TValue> get _self => this as FieldBlocState<TValue>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldBlocState<TValue> &&
          runtimeType == other.runtimeType &&
          _self.isEnabled == other.isEnabled &&
          _self.isValidating == other.isValidating &&
          _self.isDirty == other.isDirty &&
          _self.initialValue == other.initialValue &&
          _self.updatedValue == other.updatedValue &&
          _self.value == other.value &&
          _self.error == other.error;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isEnabled.hashCode);
    hashCode = $hashCombine(hashCode, _self.isValidating.hashCode);
    hashCode = $hashCombine(hashCode, _self.isDirty.hashCode);
    hashCode = $hashCombine(hashCode, _self.initialValue.hashCode);
    hashCode = $hashCombine(hashCode, _self.updatedValue.hashCode);
    hashCode = $hashCombine(hashCode, _self.value.hashCode);
    hashCode = $hashCombine(hashCode, _self.error.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('FieldBlocState', [TValue])
        ..add('isEnabled', _self.isEnabled)
        ..add('isValidating', _self.isValidating)
        ..add('isDirty', _self.isDirty)
        ..add('initialValue', _self.initialValue)
        ..add('updatedValue', _self.updatedValue)
        ..add('value', _self.value)
        ..add('error', _self.error))
      .toString();
  FieldBlocState<TValue> change(void Function(_FieldBlocStateChanges<TValue> c) updates) =>
      (_FieldBlocStateChanges<TValue>._(_self)..update(updates)).build();
  _FieldBlocStateChanges<TValue> toChanges() => _FieldBlocStateChanges._(_self);
}

class _FieldBlocStateChanges<TValue> {
  _FieldBlocStateChanges._(FieldBlocState<TValue> dc)
      : isEnabled = dc.isEnabled,
        isValidating = dc.isValidating,
        isDirty = dc.isDirty,
        initialValue = dc.initialValue,
        updatedValue = dc.updatedValue,
        value = dc.value,
        error = dc.error;

  bool isEnabled;

  bool isValidating;

  bool isDirty;

  TValue initialValue;

  TValue updatedValue;

  TValue value;

  Object? error;

  void update(void Function(_FieldBlocStateChanges<TValue> c) updates) => updates(this);

  FieldBlocState<TValue> build() => FieldBlocState(
        isEnabled: isEnabled,
        isValidating: isValidating,
        isDirty: isDirty,
        initialValue: initialValue,
        updatedValue: updatedValue,
        value: value,
        error: error,
      );
}
