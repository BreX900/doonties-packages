import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/src/bin/bin.dart';
import 'package:mekart/src/bin/bin_base.dart';

class CachedBin<T> implements BinBase<T> {
  final Bin<T> _bin;
  late final StreamSubscription<T> _subscription;
  T _data;

  CachedBin._(this._bin, this._data) {
    _subscription = _bin.onChanges.listen((data) => _data = data);
  }

  static Future<CachedBin<T>> getInstance<T>(Bin<T> bin) async {
    final data = await bin.read();
    return CachedBin._(bin, data);
  }

  @override
  Stream<T> get onChanges => _bin.onChanges;

  @override
  Stream<T> get stream => _bin.stream;

  @override
  T read() => _data;

  @override
  Future<void> write(T data) async {
    await _bin.write(data);
  }

  @override
  Future<void> update(T Function(T data) updater) async {
    await _bin.update(updater);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _bin.close();
  }

  @override
  String toString() => 'CachedBin($_bin)';
}

extension BinMap<K, V> on CachedBin<Map<K, V>> {
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

extension BinIMap<K, V> on CachedBin<IMap<K, V>> {
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
