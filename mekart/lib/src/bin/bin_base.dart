import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';

typedef BinSerializer<T> = Object? Function(T data);
typedef BinDeserializer<T> = T Function(Object data);

abstract interface class BinBase<T> {
  Stream<T> get onChanges;

  Stream<T> get stream;

  Future<void> write(T data);

  FutureOr<T> read();

  Future<void> update(T Function(T data) updater);

  Future<void> close();
}

extension BinExtensions<T> on BinBase<T?> {
  Future<T> requireRead() async {
    final data = await read();
    if (data == null) throw StateError('$this not has data');
    return data;
  }

  Future<void> requireUpdate(T? Function(T data) updater) async {
    await update((data) {
      if (data == null) throw StateError('$this not has data');
      return updater(data);
    });
  }
}

extension BaseBinMap<K, V> on BinBase<Map<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, {V Function()? orElse}) async {
    final data = await read();
    if (data.containsKey(key)) return data[key] as V;
    if (orElse != null) return orElse();
    throw StateError('$this not has "$key" key');
  }

  Future<void> set(K key, V value) async => await update((data) => {...data, key: value});

  Future<void> remove(K key) async => await update((data) => {...data}..remove(key));
}

extension BaseBinIMap<K, V> on BinBase<IMap<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, {V Function()? orElse}) async {
    final data = await read();
    if (data.containsKey(key)) return data[key] as V;
    if (orElse != null) return orElse();
    throw StateError('$this not has "$key" key');
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
