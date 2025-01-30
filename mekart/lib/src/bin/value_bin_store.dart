import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/src/bin/bin_store.dart';
import 'package:mekart/src/bin/cached_bin_store.dart';

extension ValueCachedBinStoreExtension on CachedBinStore<IMap<String, Object?>> {
  CachedValueBinStore<T> value<T>(String key, T initialValue) {
    return CachedValueBinStore.fromIMap(this, key, initialValue);
  }
}

abstract class CachedValueBinStore<T> {
  const CachedValueBinStore();

  factory CachedValueBinStore.fromIMap(
    CachedBinStore<IMap<String, Object?>> bin,
    String key,
    T initialValue,
  ) = _CachedIMapValueBin<T>;

  factory CachedValueBinStore.fromMap(
    CachedBinStore<Map<String, Object?>> bin,
    String key,
    T initialValue,
  ) = _CachedMapValueBin<T>;

  Stream<T> get onChanges;

  Stream<T> get stream;

  T read();

  Future<void> write(T value);

  void Function() listen(void Function() listener) => stream.listen((_) => listener()).cancel;
}

class _CachedMapValueBin<T> extends CachedValueBinStore<T> {
  final CachedBinStore<Map<String, Object?>> _bin;
  final String _key;
  final T _fallbackValue;

  _CachedMapValueBin(this._bin, this._key, this._fallbackValue);

  @override
  Stream<T> get onChanges => _bin.onChanges.map((map) => (map[_key] as T?) ?? _fallbackValue);

  @override
  Stream<T> get stream => _bin.stream.map((map) => (map[_key] as T?) ?? _fallbackValue);

  @override
  T read() => (_bin.getOrNull(_key) ?? _fallbackValue) as T;

  @override
  Future<void> write(T value) async => await _bin.set(_key, value);
}

class _CachedIMapValueBin<T> extends CachedValueBinStore<T> {
  final CachedBinStore<IMap<String, Object?>> _bin;
  final String _key;
  final T _fallbackValue;

  _CachedIMapValueBin(this._bin, this._key, this._fallbackValue);

  @override
  Stream<T> get onChanges => _bin.onChanges.map((map) => (map[_key] as T?) ?? _fallbackValue);

  @override
  Stream<T> get stream => _bin.stream.map((map) => (map[_key] as T?) ?? _fallbackValue);

  @override
  T read() => (_bin.getOrNull(_key) ?? _fallbackValue) as T;

  @override
  Future<void> write(T value) async => await _bin.set(_key, value);
}
