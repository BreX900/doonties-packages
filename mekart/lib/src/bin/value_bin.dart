import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/src/bin/bin_base.dart';
import 'package:mekart/src/bin/cached_bin.dart';

abstract class CachedValueBin<T> {
  const CachedValueBin();

  factory CachedValueBin.fromMap(CachedBin<Map<String, Object?>> bin, String key, T initialValue) =
      _CachedMapValueBin<T>;

  factory CachedValueBin.fromIMap(
      CachedBin<IMap<String, Object?>> bin, String key, T initialValue) = _CachedIMapValueBin<T>;

  Stream<T> get onChanges;

  Stream<T> get stream;

  T read();

  Future<void> write(T value);
}

class _CachedMapValueBin<T> extends CachedValueBin<T> {
  final CachedBin<Map<String, Object?>> _bin;
  final String _key;
  final T _fallbackValue;

  _CachedMapValueBin(this._bin, this._key, this._fallbackValue);

  @override
  Stream<T> get onChanges => _bin.onChanges.map((map) => (map[_key] ?? _fallbackValue) as T);

  @override
  Stream<T> get stream => _bin.stream.map((map) => (map[_key] ?? _fallbackValue) as T);

  @override
  T read() => (_bin.getOrNull(_key) ?? _fallbackValue) as T;

  @override
  Future<void> write(T value) async => await _bin.set(_key, value);
}

class _CachedIMapValueBin<T> extends CachedValueBin<T> {
  final CachedBin<IMap<String, Object?>> _bin;
  final String _key;
  final T _fallbackValue;

  _CachedIMapValueBin(this._bin, this._key, this._fallbackValue);

  @override
  Stream<T> get onChanges => _bin.onChanges.map((map) => (map[_key] ?? _fallbackValue) as T);

  @override
  Stream<T> get stream => _bin.stream.map((map) => (map[_key] ?? _fallbackValue) as T);

  @override
  T read() => (_bin.getOrNull(_key) ?? _fallbackValue) as T;

  @override
  Future<void> write(T value) async => await _bin.set(_key, value);
}
