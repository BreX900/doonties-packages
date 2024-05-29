import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/src/data/bin/_bin_utils.dart';
import 'package:mek/src/data/bin/bin_base.dart';
import 'package:mek/src/data/bin/bin_engine.dart';
import 'package:mek/src/shared/_task_processor.dart';

class Bin<T> implements BinBase<T> {
  final BinEngine _engine;
  final BinSerializer<T> _serializer;
  final BinDeserializer<T> _deserializer;
  final String _name;
  final T _fallbackData;
  final _tasks = TasksProcessor<void>();
  final _controller = StreamController<T>.broadcast(sync: true);

  factory Bin({
    BinEngine? engine,
    String name = 'default_lazy.bin',
    BinSerializer<T>? serializer,
    required BinDeserializer<T> deserializer,
    required T fallbackData,
  }) {
    if (usedBinNames.contains(name)) throw StateError('Already used "$name" bin!');

    return Bin._(
      engine: engine ?? BinEngine.instance,
      name: name,
      serializer: serializer ?? ((data) => data as Object),
      deserializer: deserializer,
      fallbackData: fallbackData,
    );
  }

  Bin._({
    required BinEngine engine,
    required String name,
    required BinSerializer<T> serializer,
    required BinDeserializer<T> deserializer,
    required T fallbackData,
  })  : _engine = engine,
        _serializer = serializer,
        _deserializer = deserializer,
        _name = name,
        _fallbackData = fallbackData;

  @override
  Stream<T> get onChanges => _controller.stream;

  @override
  Stream<T> get stream {
    return Stream.multi((controller) async {
      final data = await read();
      controller.addSync(data);
      await controller.addStream(_controller.stream);
    });
  }

  Future<T> read() async {
    final data = await _engine.read(_name);
    return data != null ? _deserializer(jsonDecode(data) as Object) : _fallbackData;
  }

  @override
  Future<void> write(T data) async {
    final rawData = jsonEncode(_serializer(data));
    final newData = data != null ? _deserializer(jsonDecode(rawData) as Object) : _fallbackData;
    _controller.add(newData);

    await _tasks.process(() async {
      await _engine.write(_name, rawData);
    });
  }

  @override
  Future<void> update(T Function(T data) updater) async {
    final data = await read();
    await write(updater(data));
  }

  @override
  Future<void> close() async {
    await _controller.close();
    usedBinNames.remove(_name);
  }

  @override
  String toString() => 'Bin<$T>($_name)';
}

extension LazyBinMap<K, V> on Bin<Map<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, V fallbackValue) async {
    final value = await getOrNull(key);
    return value ?? fallbackValue;
  }
}

extension LazyBinIMap<K, V> on Bin<IMap<K, V>> {
  Future<V?> getOrNull(K key) async {
    final data = await read();
    return data[key];
  }

  Future<V> get(K key, V fallbackValue) async {
    final value = await getOrNull(key);
    return value ?? fallbackValue;
  }
}
