import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

typedef BinSerializer<T> = Object Function(T data);
typedef BinDeserializer<T> = T Function(Object data);

abstract class BinBase<T> {
  Stream<T> get onChanges;

  Stream<T> get stream;

  Future<void> write(T data);

  FutureOr<T> read();

  Future<void> update(T Function(T data) updater);

  Future<void> close();
}

extension BaseBinMap<K, V> on BinBase<Map<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, V fallbackValue) async {
    final value = await getOrNull(key);
    return value ?? fallbackValue;
  }

  Future<void> set(K key, V value) async => await update((data) => {...data, key: value});

  Future<void> remove(K key) async => await update((data) => {...data}..remove(key));
}

extension BaseBinIMap<K, V> on BinBase<IMap<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, V fallbackValue) async {
    final value = await getOrNull(key);
    return value ?? fallbackValue;
  }

  Future<void> set(K key, V value) async => await update((data) => data.add(key, value));

  Future<void> remove(K key) async => await update((data) => data.remove(key));
}

extension BaseBinList<V> on BinBase<List<V>> {
  Future<void> add(V value) async => await update((data) => [...data, value]);

  Future<void> remove(V value) async => await update((data) => [...data]..remove(value));
}

extension BaseBinIList<V> on BinBase<IList<V>> {
  Future<void> add(V value) async => await update((data) => data.add(value));

  Future<void> remove(V value) async => await update((data) => data.remove(value));
}
