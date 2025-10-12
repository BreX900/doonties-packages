import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/src/bin/bin_connection.dart';
import 'package:mekart/src/bin/bin_engine.dart';

class BinTransaction implements BinSession {
  // @override
  // BinSession get session => this;

  final BinEngine engine;
  var _reads = <String, String?>{};
  var _writes = <String, String?>{};

  BinTransaction({required this.engine});

  static Future<T> run<T>(BinEngine engine, Future<T> Function(BinTransaction tx) body) async {
    final tx = BinTransaction(engine: engine);
    final result = await body(tx);
    await tx.flush();
    return result;
  }

  @override
  Stream<MapEntry<String, String?>> get onChanges => engine.onChanges;

  @override
  Future<String?> read(String name) async {
    if (_writes.containsKey(name)) return _writes[name];
    if (_reads.containsKey(name)) return _reads[name];

    final data = await engine.read(name);
    _reads[name] = data;
    return data;
  }

  @override
  Future<void> write(String name, String data) async {
    if (!_reads.containsKey(name)) _reads[name] = await engine.read(name);

    _writes[name] = data;
  }

  Future<void> flush() async {
    try {
      await Future.wait(
        _writes.mapTo((name, data) async {
          if (data != null) {
            await engine.write(name, data);
          } else {
            await engine.delete(name);
          }
        }),
      );
    } catch (_) {
      await Future.wait(
        _writes.keys.map((name) async {
          final data = _reads[name];
          if (data != null) {
            await engine.write(name, data);
          } else {
            await engine.delete(name);
          }
        }),
      );
      rethrow;
    } finally {
      _reads = const {};
      _writes = const {};
    }
  }

  @override
  Future<void> delete(String name) async {
    if (!_reads.containsKey(name)) _reads[name] = await engine.read(name);
    _writes[name] = null;
  }
}
