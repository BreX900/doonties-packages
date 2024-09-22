import 'dart:convert';

abstract class BasicCodec<S, T> implements Codec<S, T> {
  const BasicCodec();

  @override
  T encode(S input);

  @override
  S decode(T encoded);

  @override
  Converter<T, S> get decoder => _Converter(decode);

  @override
  Converter<S, T> get encoder => _Converter(encode);

  @override
  Codec<S, R> fuse<R>(Codec<T, R> other) {
    return _FusedCodec<S, T, R>(this, other);
  }

  /// Inverts `this`.
  ///
  /// The [encoder] and [decoder] of the resulting codec are swapped.
  @override
  Codec<T, S> get inverted => _InvertedCodec<T, S>(this);
}

class _Converter<S, T> extends Converter<S, T> {
  final T Function(S input) _converter;

  const _Converter(this._converter);

  @override
  T convert(S input) => _converter(input);
}

/// Fuses the given codecs.
///
/// In the non-chunked conversion simply invokes the non-chunked conversions in
/// sequence.
class _FusedCodec<S, M, T> extends Codec<S, T> {
  final Codec<S, M> _first;
  final Codec<M, T> _second;

  @override
  Converter<S, T> get encoder => _first.encoder.fuse<T>(_second.encoder);
  @override
  Converter<T, S> get decoder => _second.decoder.fuse<S>(_first.decoder);

  _FusedCodec(this._first, this._second);
}

class _InvertedCodec<T, S> extends Codec<T, S> {
  final Codec<S, T> _codec;

  _InvertedCodec(Codec<S, T> codec) : _codec = codec;

  @override
  Converter<T, S> get encoder => _codec.decoder;
  @override
  Converter<S, T> get decoder => _codec.encoder;

  @override
  Codec<S, T> get inverted => _codec;
}
