import 'dart:async';
import 'dart:convert';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/src/core/_param.dart';
import 'package:mek/src/data/bin/_bin_engine.dart'
    if (dart.library.io) '_bin_io_engine.dart'
    if (dart.library.html) '_bin_web_engine.dart';
import 'package:mek/src/shared/_task_processor.dart';
import 'package:rxdart/rxdart.dart';

typedef Serializer<T> = Object Function(T data);
typedef Deserializer<T> = T Function(Object data);

class Bin<T extends Object> {
  final BinEngine _engine;
  final Serializer<T> _serializer;
  final Deserializer<T> _deserializer;
  final String _prefix;
  final String _name;
  final _tasks = TasksProcessor<void>();
  final _controller = BehaviorSubject<T?>();
  final T? fallbackData;
  Param<T?>? _data;

  Bin({
    BinEngine? core,
    String prefix = '__bins__',
    required String name,
    Serializer<T>? serializer,
    required Deserializer<T> deserializer,
    this.fallbackData,
  })  : _engine = core ?? BinEngine.instance,
        _serializer = serializer ?? ((data) => data),
        _deserializer = deserializer,
        _prefix = prefix,
        _name = name {
    _controller.onListen = readOrNull;
  }

  late final ValueStream<T?> stream = _controller.stream;

  Future<void> write(T data) async {
    final rawData = jsonEncode(_serializer(data));
    _emit(_deserializer(jsonDecode(rawData) as Object));

    await _tasks.process(() async {
      await _engine.write(_prefix, _name, rawData);
    });
  }

  Future<T?> readOrNull() async {
    if (_data == null) {
      final data = await _engine.read(_prefix, _name);
      _emit(data != null ? _deserializer(jsonDecode(data) as Object) : null);
    }
    return _data!.value;
  }

  Future<T> read() async {
    final data = await readOrNull();
    if (data == null) throw StateError('$this is empty!');
    return data;
  }

  Future<void> update(T Function(T data) updater) async {
    final data = await read();
    await write(updater(data));
  }

  Future<void> delete() async {
    _emit(null);
    await _tasks.process(() async => await _engine.delete(_prefix, _name));
  }

  Future<void> close() async => await _controller.close();

  void _emit(T? data) {
    final nextData = data ?? fallbackData;
    _data = Param(nextData);
    _controller.add(nextData);
  }

  @override
  String toString() => 'Bin<$T>($_prefix#$_name)';
}

extension BinMap<K, V> on Bin<Map<K, V>> {
  Future<void> set(K key, V value) async {
    final data = await readOrNull();
    await write({...?data, key: value});
  }

  Future<V?> getOrNull(K key) async {
    final data = await readOrNull();
    return data?[key];
  }

  Future<V> get(K key) async {
    final value = await getOrNull(key);
    if (value is! V) throw StateError('"$key" not exist on $this!');
    return value;
  }

  Future<void> remove(K key) async {
    final data = await readOrNull();
    if (data == null || !data.containsKey(key)) return;
    await write({...data}..remove(key));
  }
}

extension BinIMap<K, V> on Bin<IMap<K, V>> {
  Future<void> set(K key, V value) async {
    final data = await readOrNull();
    await write(data?.add(key, value) ?? IMap({key: value}));
  }

  Future<V?> getOrNull(K key) async {
    final data = await readOrNull();
    return data?[key];
  }

  Future<V> get(K key) async {
    final value = await getOrNull(key);
    if (value is! V) throw StateError('"$key" not exist on $this!');
    return value;
  }

  Future<void> remove(K key) async {
    final data = await readOrNull();
    if (data == null || !data.containsKey(key)) return;
    await write(data.remove(key));
  }
}

extension BinList<V> on Bin<List<V>> {
  Future<void> add(V value) async {
    final data = await readOrNull();
    await write([...?data, value]);
  }

  Future<void> remove(V value) async {
    final data = await readOrNull();
    if (data == null || !data.contains(value)) return;
    await write([...data]..remove(value));
  }
}

extension BinIList<V> on Bin<IList<V>> {
  Future<void> add(V value) async {
    final data = await readOrNull();
    await write(data?.add(value) ?? IList([value]));
  }

  Future<void> remove(V value) async {
    final data = await readOrNull();
    if (data == null || !data.contains(value)) return;
    await write(data.remove(value));
  }
}
