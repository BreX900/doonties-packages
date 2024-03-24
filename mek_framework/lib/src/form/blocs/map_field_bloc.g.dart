// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_field_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$MapFieldBlocState<TKey, TValue> {
  MapFieldBlocState<TKey, TValue> get _self => this as MapFieldBlocState<TKey, TValue>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapFieldBlocState<TKey, TValue> &&
          runtimeType == other.runtimeType &&
          _self.fieldBlocs == other.fieldBlocs &&
          _self.fieldStates == other.fieldStates;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.fieldBlocs.hashCode);
    hashCode = $hashCombine(hashCode, _self.fieldStates.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('MapFieldBlocState', [TKey, TValue])
        ..add('fieldBlocs', _self.fieldBlocs)
        ..add('fieldStates', _self.fieldStates))
      .toString();
  MapFieldBlocState<TKey, TValue> change(
          void Function(_MapFieldBlocStateChanges<TKey, TValue> c) updates) =>
      (_MapFieldBlocStateChanges<TKey, TValue>._(_self)..update(updates)).build();
  _MapFieldBlocStateChanges<TKey, TValue> toChanges() => _MapFieldBlocStateChanges._(_self);
}

class _MapFieldBlocStateChanges<TKey, TValue> {
  _MapFieldBlocStateChanges._(MapFieldBlocState<TKey, TValue> dc)
      : fieldBlocs = dc.fieldBlocs,
        fieldStates = dc.fieldStates;

  IMap<TKey, FieldBlocBase<FieldBlocStateBase<TValue>, TValue>> fieldBlocs;

  IMap<TKey, FieldBlocStateBase<TValue>> fieldStates;

  void update(void Function(_MapFieldBlocStateChanges<TKey, TValue> c) updates) => updates(this);

  MapFieldBlocState<TKey, TValue> build() => MapFieldBlocState(
        fieldBlocs: fieldBlocs,
        fieldStates: fieldStates,
      );
}
