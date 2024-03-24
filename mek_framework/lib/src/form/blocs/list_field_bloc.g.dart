// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_field_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$ListFieldBlocState<TFieldBloc extends FieldBlocBase<FieldBlocStateBase<TValue>, TValue>,
    TValue> {
  ListFieldBlocState<TFieldBloc, TValue> get _self =>
      this as ListFieldBlocState<TFieldBloc, TValue>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListFieldBlocState<TFieldBloc, TValue> &&
          runtimeType == other.runtimeType &&
          $listEquality.equals(_self.fieldBlocs, other.fieldBlocs) &&
          $listEquality.equals(_self.fieldStates, other.fieldStates);
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, $listEquality.hash(_self.fieldBlocs));
    hashCode = $hashCombine(hashCode, $listEquality.hash(_self.fieldStates));
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('ListFieldBlocState', [TFieldBloc, TValue])
        ..add('fieldBlocs', _self.fieldBlocs)
        ..add('fieldStates', _self.fieldStates))
      .toString();
  ListFieldBlocState<TFieldBloc, TValue> change(
          void Function(_ListFieldBlocStateChanges<TFieldBloc, TValue> c) updates) =>
      (_ListFieldBlocStateChanges<TFieldBloc, TValue>._(_self)..update(updates)).build();
  _ListFieldBlocStateChanges<TFieldBloc, TValue> toChanges() => _ListFieldBlocStateChanges._(_self);
}

class _ListFieldBlocStateChanges<
    TFieldBloc extends FieldBlocBase<FieldBlocStateBase<TValue>, TValue>, TValue> {
  _ListFieldBlocStateChanges._(ListFieldBlocState<TFieldBloc, TValue> dc)
      : fieldBlocs = dc.fieldBlocs,
        fieldStates = dc.fieldStates;

  List<TFieldBloc> fieldBlocs;

  List<FieldBlocStateBase<TValue>> fieldStates;

  void update(void Function(_ListFieldBlocStateChanges<TFieldBloc, TValue> c) updates) =>
      updates(this);

  ListFieldBlocState<TFieldBloc, TValue> build() => ListFieldBlocState(
        fieldBlocs: fieldBlocs,
        fieldStates: fieldStates,
      );
}
