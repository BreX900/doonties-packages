import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

extension IterableIExtensions<E> on Iterable<E> {
  IList<E> toIListWithConfig(ConfigList config) => IList.withConfig(this, config);

  ISet<E> toISetWithConfig(ConfigSet config) => ISet.withConfig(this, config);

  IMap<K, IList<E>> groupIListsBy<K>(K Function(E element) keyOf) =>
      groupListsBy(keyOf).asIMap().map((key, value) => MapEntry(key, value.asIList()));
}

extension ListIExtensions<E> on List<E> {
  IList<E> asIList([ConfigList? config]) =>
      IList.unsafe(this, config: config ?? IList.defaultConfig);
}

extension SetIExtensions<E> on Set<E> {
  ISet<E> asIList([ConfigSet? config]) => ISet.unsafe(this, config: config ?? ISet.defaultConfig);
}

extension MapIExtensions<K, V> on Map<K, V> {
  IMap<K, V> asIMap([ConfigMap? config]) => IMap.unsafe(this, config: config ?? IMap.defaultConfig);
}

extension EntriesIterableIExtensions<K, V> on Iterable<MapEntry<K, V>> {
  IMap<K, V> toIMap([ConfigMap? config]) => IMap.fromEntries(this, config: config);
}
