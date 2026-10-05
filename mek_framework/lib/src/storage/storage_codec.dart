part of 'storage.dart';

mixin StorageCodec<Fine, Raw> {
  static StorageCodec<R, R> none<R>() => _StorageCodecNone<R>();

  static StorageCodec<Fine, Raw> cast<Fine, Raw>() => _StorageCodecCast<Fine, Raw>();

  static StorageCodec<R, R?> fallback<R>(R value) => _StorageCodecFallback(value);

  static const StorageCodec<Object?, String?> json = _StorageCodecJson();

  static StorageCodec<Fine?, Raw?> from<Fine, Raw>({
    required Fine Function(Raw data) decoder,
    required Raw? Function(Fine data) encoder,
  }) => _StorageCodecBuilder<Fine, Raw>(decoder, encoder);

  Fine decode(Raw data);

  Raw encode(Fine data);

  StorageCodec<R, Raw> fuse<R>(StorageCodec<R, Fine> codec) => _StorageCodecFuse(this, codec);

  @override
  String toString() => '$runtimeType';
}

class _StorageCodecFuse<Fine, T, Raw> with StorageCodec<Fine, Raw> {
  final StorageCodec<T, Raw> _left;
  final StorageCodec<Fine, T> _right;

  _StorageCodecFuse(this._left, this._right);

  @override
  Fine decode(Raw data) => _right.decode(_left.decode(data));

  @override
  Raw encode(Fine data) => _left.encode(_right.encode(data));

  @override
  String toString() => '$_left <=> $_right';
}

class _StorageCodecNone<T> with StorageCodec<T, T> {
  const _StorageCodecNone();

  @override
  T decode(T data) => data;

  @override
  T encode(T data) => data;

  @override
  String toString() => 'None<$T>()';
}

class _StorageCodecCast<Fine, Raw> with StorageCodec<Fine, Raw> {
  const _StorageCodecCast();

  @override
  Fine decode(Raw data) {
    assert(data is Fine, 'Cant cast $Raw to $Fine.\n$data');
    return data as Fine;
  }

  @override
  Raw encode(Fine data) {
    assert(data is Raw, 'Cant cast $Fine to $Raw.\n$data');
    return data as Raw;
  }

  @override
  String toString() => 'Cast<$Fine,$Raw>()';
}

class _StorageCodecFallback<T> with StorageCodec<T, T?> {
  final T _value;

  const _StorageCodecFallback(this._value);

  @override
  T decode(T? data) => data ?? _value;

  @override
  T? encode(T? data) => data;

  @override
  String toString() => 'Fallback<$T>($_value)';
}

class _StorageCodecJson with StorageCodec<Object?, String?> {
  const _StorageCodecJson();

  @override
  Object? decode(String? data) => data != null ? jsonDecode(data) : null;

  @override
  String? encode(Object? data) => data != null ? jsonEncode(data) : null;

  @override
  String toString() => 'Json()';
}

class _StorageCodecBuilder<Fine, Raw> with StorageCodec<Fine?, Raw?> {
  final Fine Function(Raw data) _decoder;
  final Raw? Function(Fine data) _encoder;

  _StorageCodecBuilder(this._decoder, this._encoder);

  @override
  Fine? decode(Raw? data) => data != null ? _decoder(data) : null;

  @override
  Raw? encode(Fine? data) => data != null ? _encoder(data) : null;

  @override
  String toString() => 'Builder<$Fine,$Raw>()';
}

Object? _toJson(Object? value) {
  switch (value) {
    case null || bool() || num() || String():
      return value;
    case List():
      return value.map(_toJson).toList();
    case Map<String, dynamic>():
      return value.map((key, value) => MapEntry(key, _toJson(value)));
    default:
      try {
        return _toJson((value as dynamic).toJson());
      } on Object {
        return throw UnsupportedError('Not supported ${value.runtimeType}!');
      }
  }
}
