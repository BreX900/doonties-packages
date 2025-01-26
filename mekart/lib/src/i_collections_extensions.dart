import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension IterableIExtensions<E> on Iterable<E> {
  IList<E> toIListWithConfig(ConfigList config) => IList.withConfig(this, config);

  ISet<E> toISetWithConfig(ConfigSet config) => ISet.withConfig(this, config);

  IMap<K, IList<E>> groupIListsBy<K>(K Function(E element) keyOf) =>
      groupListsBy(keyOf).mapTo((key, value) => MapEntry(key, value.lockUnsafe)).toIMap();
}

extension IMapExtensions<K, V> on IMap<K, V> {
  V require(K key, {V Function()? orElse}) {
    if (containsKey(key)) return this[key] as V;
    if (orElse != null) return orElse();
    throw StateError('IMap<$K, $V> not contains "$key" key');
  }
}

extension ListRoExtensions<T> on List<T> {
  List<T> asUnmodifiable() => this is UnmodifiableListView<T> ? this : UnmodifiableListView(this);
  @Deprecated('In favour of lockUnsafe')
  IList<T> asImmutable([ConfigList? config]) =>
      IList.unsafe(this, config: config ?? IList.defaultConfig);
}

extension IListRoExtensions<T> on IList<T> {
  @Deprecated('In favour of unlockView')
  List<T> asUnmodifiable() => unlockView;

  // ignore: avoid_positional_boolean_parameters
  IList<T> toggle(bool isAdding, T value) => isAdding ? add(value) : remove(value);
}

extension SetRoExtensions<T> on Set<T> {
  Set<T> asUnmodifiable() => this is UnmodifiableSetView<T> ? this : UnmodifiableSetView(this);
  @Deprecated('In favour of lockUnsafe')
  ISet<T> asImmutable([ConfigSet? config]) =>
      ISet.unsafe(this, config: config ?? ISet.defaultConfig);
}

extension ISetRoExtensions<T> on ISet<T> {
  @Deprecated('In favour of unlockView')
  Set<T> asUnmodifiable() => unlockView;

  // ignore: avoid_positional_boolean_parameters
  ISet<T> toggle(bool isAdding, T value) => isAdding ? add(value) : remove(value);
}

extension MapRoExtensions<K, V> on Map<K, V> {
  Map<K, V> asUnmodifiable() =>
      this is UnmodifiableMapView<K, V> ? this : UnmodifiableMapView(this);
  @Deprecated('In favour of lockUnsafe')
  IMap<K, V> asImmutable([ConfigMap? config]) =>
      IMap.unsafe(this, config: config ?? IMap.defaultConfig);
}

extension IMapRoExtensions<K, V> on IMap<K, V> {
  @Deprecated('In favour of unlockView')
  Map<K, V> asUnmodifiable() => unlockView;
}

extension EntriesRoExtensions<K, V> on Iterable<MapEntry<K, V>> {
  IMap<K, V> toIMap([ConfigMap? config]) =>
      IMap.fromEntries(this, config: config ?? IMap.defaultConfig);
}
