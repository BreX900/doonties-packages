import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:mekart/src/bin/bin_base.dart';
import 'package:mekart/src/bin/bin_engine.dart';
import 'package:synchronized/synchronized.dart';

class Bin<T> implements BinBase<T> {
  static final Set<String> _usedNames = HashSet();

  final BinEngine _engine;
  final BinSerializer<T> _serializer;
  final BinDeserializer<T> _deserializer;
  final String _name;
  final T _fallbackData;
  final JsonEncoder _encoder;
  final _lock = Lock();
  final _controller = StreamController<T>.broadcast(sync: true);

  factory Bin({
    BinEngine? engine,
    String name = '_default.bin',
    BinSerializer<T>? serializer,
    required BinDeserializer<T> deserializer,
    required T fallbackData,
    JsonEncoder encoder = const JsonEncoder(),
  }) {
    if (_usedNames.contains(name)) throw StateError('Already used "$name" bin!');

    return Bin._(
      engine: engine ?? BinEngine.instance,
      name: name,
      serializer: serializer ?? ((data) => data as Object),
      deserializer: deserializer,
      fallbackData: fallbackData,
      encoder: encoder,
    );
  }

  Bin._({
    required BinEngine engine,
    required String name,
    required BinSerializer<T> serializer,
    required BinDeserializer<T> deserializer,
    required T fallbackData,
    required JsonEncoder encoder,
  })  : _engine = engine,
        _serializer = serializer,
        _deserializer = deserializer,
        _name = name,
        _fallbackData = fallbackData,
        _encoder = encoder;

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

  @override
  Future<T> read() async {
    final data = await _engine.read(_name);
    return data != null ? _deserializer(jsonDecode(data) as Object) : _fallbackData;
  }

  @override
  Future<void> write(T data) async {
    final rawData = _encoder.convert(_serializer(data));
    final newData = data != null ? _deserializer(jsonDecode(rawData) as Object) : _fallbackData;
    _controller.add(newData);

    await _lock.synchronized(() async => await _engine.write(_name, rawData));
  }

  @override
  Future<void> update(T Function(T data) updater) async {
    final data = await read();
    await write(updater(data));
  }

  Future<void> clear() async {
    await _lock.synchronized(() async => await _engine.delete(_name));
  }

  @override
  Future<void> close() async {
    await _controller.close();
    _usedNames.remove(_name);
  }

  @override
  String toString() => 'Bin<$T>($_name)';
}
