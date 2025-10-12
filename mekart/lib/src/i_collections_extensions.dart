import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension IterableIExtensions<E> on Iterable<E> {
  IList<E> toIListWithConfig(ConfigList config) => IList.withConfig(this, config);

  ISet<E> toISetWithConfig(ConfigSet config) => ISet.withConfig(this, config);

  IMap<K, IList<E>> groupIListsBy<K>(K Function(E element) keyOf) =>
      groupListsBy(keyOf).mapTo((key, value) => MapEntry(key, value.lockUnsafe)).toIMap();
}

extension IListExtensions<T> on IList<T> {
  // ignore: avoid_positional_boolean_parameters
  IList<T> toggle(bool isAdding, T value) => isAdding ? add(value) : remove(value);

  IList<T> move(T target, T destination, {bool after = false}) {
    final fixedList = remove(target);
    final index = fixedList.indexOf(destination);
    return fixedList.insert(after ? index + 1 : index, target);
  }
}

extension ISetExtensions<T> on ISet<T> {
  // ignore: avoid_positional_boolean_parameters
  ISet<T> toggle(bool isAdding, T value) => isAdding ? add(value) : remove(value);
}

extension IMapExtensions<K, V> on IMap<K, V> {
  V require(K key, {V Function()? orElse}) {
    if (containsKey(key)) return this[key] as V;
    if (orElse != null) return orElse();
    throw StateError('IMap<$K, $V> not contains "$key" key');
  }
}

extension NonNullsIMapExtensions<K extends Object, V extends Object> on IMap<K?, V?> {
  IMap<K, V> get nonNulls => <K, V>{
    for (final MapEntry(:key, :value) in entries)
      if (key != null && value != null) key: value,
  }.lockUnsafe;
}

extension NonNullValuesIMapExtensions<K, V extends Object> on IMap<K, V?> {
  IMap<K, V> get nonNullValues => <K, V>{
    for (final MapEntry(:key, :value) in entries)
      if (value != null) key: value,
  }.lockUnsafe;
}

extension NonNullKeysIMapExtensions<K extends Object, V> on IMap<K?, V> {
  IMap<K, V> get nonNullKeys => <K, V>{
    for (final MapEntry(:key, :value) in entries)
      if (key != null) key: value,
  }.lockUnsafe;
}

extension EntriesIMapExtensions<K, V> on Iterable<MapEntry<K, V>> {
  IMap<K, V> toIMap([ConfigMap? config]) =>
      IMap.fromEntries(this, config: config ?? IMap.defaultConfig);
}
