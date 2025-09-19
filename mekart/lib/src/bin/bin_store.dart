import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/src/bin/bin_connection.dart';

typedef BinSerializer<T> = Object? Function(T data);
typedef BinDeserializer<T> = T Function(Object data);

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

  Stream<T> get onChanges =>
      _session.onChanges.where((e) => e.key == name).map((e) => _deserialize(e.value));

  Stream<T> get stream {
    return Stream.multi((controller) async {
      try {
        final data = await read();
        controller.addSync(data);
      } catch (error, stackTrace) {
        controller.addErrorSync(error, stackTrace);
      }
      await controller.addStream(onChanges);
    });
  }

  FutureOr<T> read() async {
    final data = await _session.read(name);
    return _deserialize(data);
  }

  Future<void> write(T data) async {
    await _session.write(name, _codec.encode(_serializer(data)));
  }

  Future<void> delete() async {
    await _session.delete(name);
  }

  T _deserialize(String? data) {
    if (data == null) return _fallbackData;
    final decodedData = _codec.decode(data);
    if (decodedData == null) return _fallbackData;
    return _deserializer(decodedData);
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

abstract class SerializableKey<Fine, Raw> {
  String get name;

  const SerializableKey();

  static SerializableKey<T, T> of<T>(String name) => _SimpleSerializableKey(name);

  Fine deserialize(Raw data);
  Raw serialize(Fine data);

  SerializableKey<R, Raw> map<R>(
    R Function(Fine data) deserializer,
    Fine Function(R data) serializer,
  ) {
    return _MappedStorageKey(this, deserializer, serializer);
  }
}

extension on SerializableKey<String, String> {
  SerializableKey<R, String> mapJson<R>(
    R Function(Object data) deserializer,
    Object Function(R data) serializer,
  ) {
    return _JsonStorageKey(this, deserializer, serializer);
  }
}

class _SimpleSerializableKey<T> extends SerializableKey<T, T> {
  @override
  final String name;

  const _SimpleSerializableKey(this.name);

  @override
  T deserialize(T data) => data;
  @override
  T serialize(T data) => data;
}

class _MappedStorageKey<Fine, T, Raw> extends SerializableKey<Fine, Raw> {
  final SerializableKey<T, Raw> _key;
  final Fine Function(T json) _deserializer;
  final T Function(Fine instance) _serializer;

  @override
  String get name => _key.name;

  const _MappedStorageKey(this._key, this._deserializer, this._serializer);

  @override
  Fine deserialize(Raw data) => _deserializer(_key.deserialize(data));
  @override
  Raw serialize(Fine instance) => _key.serialize(_serializer(instance));
}

class _JsonStorageKey<Fine> extends SerializableKey<Fine, String> {
  final SerializableKey<String, String> _key;
  final Fine Function(Object json) _deserializer;
  final Object Function(Fine instance) _serializer;

  @override
  String get name => _key.name;

  const _JsonStorageKey(this._key, this._deserializer, this._serializer);

  @override
  Fine deserialize(String data) => _deserializer(jsonDecode(_key.deserialize(data)) as Object);
  @override
  String serialize(Fine instance) => _key.serialize(jsonEncode(_serializer(instance)));
}
