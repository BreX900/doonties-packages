import 'dart:convert';

import 'package:mekart/src/bin/bin_base.dart';
import 'package:mekart/src/bin_v2/bin_connection.dart';

class JsonCodecWithIndent extends Codec<Object?, String> {
  final String? indent;

  const JsonCodecWithIndent(this.indent);

  @override
  Converter<String, Object?> get decoder => const JsonDecoder();

  @override
  Converter<Object?, String> get encoder => JsonEncoder.withIndent(indent);
}

class BinStore<T> {
  final BinSession session;
  final String name;
  final Codec<Object?, String> _codec;
  final BinDeserializer<T> _deserializer;
  final BinSerializer<T> _serializer;
  final T _fallbackData;

  BinStore({
    required this.session,
    required this.name,
    Codec<Object?, String> codec = const JsonCodec(),
    required BinDeserializer<T> deserializer,
    BinSerializer<T> serializer = _serialize,
    required T fallbackData,
  })  : _codec = codec,
        _deserializer = deserializer,
        _serializer = serializer,
        _fallbackData = fallbackData;

  Future<T> read() async {
    final data = await session.read(name);
    if (data == null) return _fallbackData;
    final decodedData = _codec.decode(data);
    if (decodedData == null) return _fallbackData;
    return _deserializer(decodedData);
  }

  Future<void> write(T data) async {
    await session.write(name, _codec.encode(_serializer(data)));
  }

  Future<void> delete() async {
    await session.delete(name);
  }

  static Object? _serialize(Object? data) => data;
}
