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
