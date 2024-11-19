import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/src/bin/bin_connection.dart';

typedef BinSerializer<T> = Object? Function(T data);
typedef BinDeserializer<T> = T Function(Object data);

class JsonCodecWithIndent extends Codec<Object?, String> {
  final String? indent;

  const JsonCodecWithIndent(this.indent);

  @override
  Converter<String, Object?> get decoder => const JsonDecoder();

  @override
  Converter<Object?, String> get encoder => JsonEncoder.withIndent(indent);
}

class BinStore<T> {
  final BinSession _session;
  final String name;
  final Codec<Object?, String> _codec;
  final BinDeserializer<T> _deserializer;
  final BinSerializer<T> _serializer;
  final T _fallbackData;

  BinStore({
    required BinSession session,
    required this.name,
    Codec<Object?, String> codec = const JsonCodec(),
    required BinDeserializer<T> deserializer,
    BinSerializer<T> serializer = _serialize,
    required T fallbackData,
  })  : _session = session,
        _codec = codec,
        _deserializer = deserializer,
        _serializer = serializer,
        _fallbackData = fallbackData;

  final _controller = StreamController<T>.broadcast();

  Stream<T> get onChanges => _controller.stream;

  Stream<T> get stream async* {
    yield await read();
    yield* _controller.stream;
  }

  FutureOr<T> read() async {
    final data = await _session.read(name);
    if (data == null) return _fallbackData;
    final decodedData = _codec.decode(data);
    if (decodedData == null) return _fallbackData;
    return _deserializer(decodedData);
  }

  Future<void> write(T data) async {
    await _session.write(name, _codec.encode(_serializer(data)));
  }

  Future<void> delete() async {
    await _session.delete(name);
  }

  void dispose() {
    unawaited(_controller.close());
  }

  static Object? _serialize(Object? data) => data;
}

extension BinExtensions<T> on BinStore<T?> {
  Future<T> requireRead() async {
    final data = await read();
    if (data == null) throw StateError('$this not has data');
    return data;
  }
}

extension BaseBinMap<K, V> on BinStore<Map<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, {V Function()? orElse}) async {
    final data = await read();
    if (data.containsKey(key)) return data[key] as V;
    if (orElse != null) return orElse();
    throw StateError('$this not has "$key" key');
  }

  Future<void> set(K key, V value) async {
    final data = await read();
    await write({...data, key: value});
  }

  Future<void> remove(K key) async {
    final data = await read();
    await write({...data}..remove(key));
  }
}

extension BaseBinIMap<K, V> on BinStore<IMap<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, {V Function()? orElse}) async {
    final data = await read();
    if (data.containsKey(key)) return data[key] as V;
    if (orElse != null) return orElse();
    throw StateError('$this not has "$key" key');
  }

  Future<void> set(K key, V value) async {
    final data = await read();
    await write(data.add(key, value));
  }

  Future<void> remove(K key) async {
    final data = await read();
    await write(data.remove(key));
  }
}

extension BaseBinList<V> on BinStore<List<V>> {
  Future<void> add(V value) async {
    final data = await read();
    await write([...data, value]);
  }

  Future<void> remove(V value) async {
    final data = await read();
    await write([...data]..remove(value));
  }
}

extension BaseBinIList<V> on BinStore<IList<V>> {
  Future<void> add(V value) async {
    final data = await read();
    await write(data.add(value));
  }

  Future<void> remove(V value) async {
    final data = await read();
    await write(data.remove(value));
  }
}
