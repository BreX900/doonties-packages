import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/mekart.dart';

class CachedBinStore<T> implements BinStore<T> {
  final BinStore<T> _bin;
  late final StreamSubscription<T> _subscription;
  T _data;

  CachedBinStore._(this._bin, this._data) {
    _subscription = _bin.onChanges.listen((data) => _data = data);
  }

  static Future<CachedBinStore<T>> getInstance<T>(BinStore<T> bin) async {
    final data = await bin.read();
    return CachedBinStore._(bin, data);
  }

  @override
  String get name => _bin.name;

  @override
  Stream<T> get onChanges => _bin.onChanges;

  @override
  Stream<T> get stream => _bin.stream;

  @override
  T read() => _data;

  @override
  Future<void> write(T data) async => await _bin.write(data);

  @override
  Future<void> delete() async => await _bin.delete();

  @override
  void dispose() => unawaited(_subscription.cancel());

  @override
  String toString() => 'CachedBin($_bin)';
}

extension BinMapStore<K, V> on CachedBinStore<Map<K, V>> {
  V? getOrNull(K key) {
    final data = read();
    return data[key];
  }

  V get(K key, {V Function()? orElse}) {
    final data = read();
    if (data.containsKey(key)) return data[key] as V;
    if (orElse != null) return orElse();
    throw StateError('$this not has "$key" key');
  }
}

extension BinIMapStore<K, V> on CachedBinStore<IMap<K, V>> {
  V? getOrNull(K key) {
    final data = read();
    return data[key];
  }

  V get(K key, {V Function()? orElse}) {
    final data = read();
    if (data.containsKey(key)) return data[key] as V;
    if (orElse != null) return orElse();
    throw StateError('$this not has "$key" key');
  }
}
