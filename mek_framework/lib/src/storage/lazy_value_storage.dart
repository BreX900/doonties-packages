part of 'storage.dart';

mixin LazyValueStorage<T> {
  Stream<T> get stream;

  Future<T> read();

  Future<void> write(T value);

  Future<void> delete();

  LazyValueStorage<R> withCodec<R>(StorageCodec<R, T> codec);

  LazyValueStorage<R?> withCastCodec<R>() => withCodec(.cast<R?, T>());
}

extension FallbackLazyValueStorageExtension<T> on LazyValueStorage<T?> {
  LazyValueStorage<T> withFallbackCodec(T value) => withCodec(.fallback(value));

  Future<T> requireRead() async =>
      ArgumentError.checkNotNull(await read(), '$this contains null value');
}

extension CodersLazyValueStorageExtension<T> on LazyValueStorage<T?> {
  LazyValueStorage<R?> withCoders<R>(R Function(T data) decoder, T? Function(R data) encoder) =>
      withCodec<R?>(.from<R, T>(decoder: decoder, encoder: encoder));
}

extension JsonCodersLazyValueStorageExtension on LazyValueStorage<Object?> {
  LazyValueStorage<R?> withJsonCoders<R>(
    R Function(Object data) decoder, [
    Object Function(R data)? encoder,
  ]) => withCodec<R?>(.from<R, Object>(decoder: decoder, encoder: encoder ?? _toJson));
}

extension JsonLazyValueStorageExtension on LazyValueStorage<String?> {
  LazyValueStorage<R?> withJsonEncoding<R>(R Function(Object data) decoder) =>
      withCodec(.json).withJsonCoders(decoder);
}

class _LazyValueStorageWithCodec<Fine, Raw> with LazyValueStorage<Fine> {
  final LazyStorage<Raw> _store;
  final String _key;
  final StorageCodec<Fine, Raw> _codec;

  _LazyValueStorageWithCodec(this._store, this._key, this._codec);

  @override
  Stream<Fine> get stream => _store.watch(_key).map(_codec.decode);

  @override
  Future<Fine> read() async {
    final data = await _store.read(_key);
    return _codec.decode(data);
  }

  @override
  Future<void> write(Fine value) {
    final data = _codec.encode(value);
    return _store.write(_key, data);
  }

  @override
  Future<void> delete() async {
    await _store.delete(_key);
  }

  @override
  LazyValueStorage<R> withCodec<R>(StorageCodec<R, Fine> codec) =>
      _LazyValueStorageWithCodec<R, Raw>(_store, _key, _codec.fuse<R>(codec));

  @override
  String toString() => '$_store($_key, $_codec)';
}
