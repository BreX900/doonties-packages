import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/mek.dart';

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
}

extension BinMap<K, V> on CachedBin<Map<K, V>> {
  V? getOrNull(K key) {
    final data = read();
    return data[key];
  }

  V get(K key, V fallbackValue) {
    final value = getOrNull(key);
    return value ?? fallbackValue;
  }
}

extension BinIMap<K, V> on CachedBin<IMap<K, V>> {
  V? getOrNull(K key) {
    final data = read();
    return data[key];
  }

  V get(K key, V fallbackValue) {
    final value = getOrNull(key);
    return value ?? fallbackValue;
  }
}
