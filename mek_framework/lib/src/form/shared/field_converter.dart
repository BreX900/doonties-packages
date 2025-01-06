import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';

abstract class FieldConverter<TBlocValue, TVIewValue> {
  const FieldConverter();

  TVIewValue convertForView(FieldBlocRule<TBlocValue> fieldBloc, TBlocValue blocValue);

  TBlocValue convertForBloc(FieldBlocRule<TBlocValue> fieldBloc, TVIewValue viewValue);
}

// class _FieldConverter<T> extends FieldConverter<dynamic, T> {
//   const _FieldConverter();
//
//   @override
//   // ignore: avoid_annotating_with_dynamic
//   T convertForView(dynamic blocValue) => blocValue;
//
//   @override
//   dynamic convertForBloc(T viewValue) => viewValue;
// }

class DefaultFieldConverter<T> extends FieldConverter<T, T> {
  @Deprecated('In favour of reactive_forms')
  const DefaultFieldConverter();

  @override
  T convertForView(FieldBlocRule<T> fieldBloc, T blocValue) => blocValue;

  @override
  T convertForBloc(FieldBlocRule<T> fieldBloc, T viewValue) => viewValue;
}

class SetFieldConverter<T> extends FieldConverter<T, Set<T>> {
  final bool emptyIfNull;

  @Deprecated('In favour of reactive_forms')
  const SetFieldConverter({this.emptyIfNull = false});

  @override
  Set<T> convertForView(FieldBlocRule<T> fieldBloc, T blocValue) =>
      blocValue == null && emptyIfNull ? {} : {blocValue};

  @override
  T convertForBloc(FieldBlocRule<T> fieldBloc, Set<T> viewValue) => viewValue.singleOrNull as T;
}

class MapKeysFieldConverter<K, V> extends FieldConverter<IMap<K, V>, ISet<K>> {
  final V initialValue;

  @Deprecated('In favour of reactive_forms')
  const MapKeysFieldConverter(this.initialValue);

  @override
  IMap<K, V> convertForBloc(FieldBlocRule<IMap<K, V>> fieldBloc, ISet<K> viewValue) =>
      IMap.fromKeys(
        keys: viewValue,
        valueMapper: (key) => fieldBloc.state.value[key] ?? initialValue,
      );

  @override
  ISet<K> convertForView(FieldBlocRule<IMap<K, V>> fieldBloc, IMap<K, V> blocValue) =>
      blocValue.keys.toISet();
}

class MapValueFieldConverter<K, V> extends FieldConverter<IMap<K, V>, V> {
  final K key;
  final V initialValue;

  @Deprecated('In favour of reactive_forms')
  const MapValueFieldConverter(this.key, this.initialValue);

  @override
  IMap<K, V> convertForBloc(FieldBlocRule<IMap<K, V>> fieldBloc, V viewValue) =>
      fieldBloc.state.value.add(key, viewValue);

  @override
  V convertForView(FieldBlocRule<IMap<K, V>> fieldBloc, IMap<K, V> blocValue) =>
      blocValue[key] ?? initialValue;
}
