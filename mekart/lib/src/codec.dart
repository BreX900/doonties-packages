import 'dart:convert';

import 'package:meta/meta.dart';

class JsonCodecWithIndent extends Codec<Object?, String> {
  final String? indent;

  const JsonCodecWithIndent(this.indent);

  @override
  Converter<String, Object?> get decoder => const JsonDecoder();

  @override
  Converter<Object?, String> get encoder => JsonEncoder.withIndent(indent);
}

class CodecBuilder<S, T> extends SimpleCodec<S, T> {
  final S Function(T encoded) _decoder;
  final T Function(S input) _encoder;

  CodecBuilder({required this._decoder, required this._encoder});

  @override
  S decode(T encoded) => _decoder(encoded);

  @override
  T encode(S input) => _encoder(input);
}

class NoneCodec<I, O> extends SimpleCodec<I, O> {
  const NoneCodec();

  @override
  O encode(I input) => input as O;

  @override
  I decode(O encoded) => encoded as I;
}

abstract class SimpleCodec<I, O> extends Codec<I, O> {
  const SimpleCodec();

  @override
  Converter<I, O> get encoder => _Converter(encode);

  @override
  Converter<O, I> get decoder => _Converter(decode);

  @mustBeOverridden
  @override
  O encode(I input);

  @mustBeOverridden
  @override
  I decode(O encoded);
}

class _Converter<I, O> extends Converter<I, O> {
  final O Function(I input) converter;

  const _Converter(this.converter);

  @override
  O convert(I input) => converter(input);
}
