part of 'storage.dart';

mixin ValueStorage<T> {
  ValueObservable<T> get observable;

  T read();

  Future<void> write(T value);

  Future<void> delete();

  ValueStorage<R> withCodec<R>(StorageCodec<R, T> codec);

  ValueStorage<R?> withCastCodec<R>() => withCodec(.cast<R?, T>());
}

extension FallbackValueStorageExtension<T> on ValueStorage<T?> {
  ValueStorage<T> withFallbackCodec(T value) => withCodec(.fallback(value));

  T requireRead() => ArgumentError.checkNotNull(read(), '$this contains null value');
}

extension CodersValueStorageExtension<T> on ValueStorage<T?> {
  ValueStorage<R?> withCoders<R>(R Function(T data) decoder, T? Function(R data) encoder) =>
      withCodec<R?>(.from<R, T>(decoder: decoder, encoder: encoder));
}

extension JsonCodersValueStorageExtension on ValueStorage<Object?> {
  ValueStorage<R?> _withJsonCoders<R>(
    R Function(Object data) decoder, [
    Object Function(R data)? encoder,
  ]) => withCodec<R?>(.from<R, Object>(decoder: decoder, encoder: encoder ?? _toJson));
}

extension JsonValueStorageExtension on ValueStorage<String?> {
  ValueStorage<R?> withJsonEncoding<R>(R Function(Object data) decoder) =>
      withCodec(.json)._withJsonCoders(decoder);
}

class _ValueStorageWithCodec<Fine, Raw> with ValueStorage<Fine> {
  final Storage<Raw> _store;
  final String _key;
  final StorageCodec<Fine, Raw> _codec;

  _ValueStorageWithCodec(this._store, this._key, this._codec);

  @override
  ValueObservable<Fine> get observable => _store.watch(_key).select(_codec.decode);

  @override
  Fine read() {
    final data = _store.read(_key);
    return _codec.decode(data);
  }

  @override
  Future<void> write(Fine value) {
    final data = _codec.encode(value);
    return _store.write(_key, data);
  }

  @override
  ValueStorage<R> withCodec<R>(StorageCodec<R, Fine> codec) =>
      _ValueStorageWithCodec<R, Raw>(_store, _key, _codec.fuse<R>(codec));

  @override
  Future<void> delete() => _store.delete(_key);
}
