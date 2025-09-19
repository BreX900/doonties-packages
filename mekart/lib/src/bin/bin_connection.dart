import 'dart:async';

import 'package:mekart/src/bin/bin_engine.dart';
import 'package:mekart/src/bin/bin_transaction.dart';
import 'package:synchronized/synchronized.dart';

// abstract interface class BinCollection {
//   BinSession get session;
// }
//
// abstract interface class BinDatabase implements BinCollection {
//   @override
//   BinConnection get session;
//
//   Future<R> runTransaction<R>(Future<R> Function(BinCollection tx) body) async {
//     return session.runTransaction(body);
//   }
// }

abstract class BinSession {
  // @override
  // BinSession get session => this;

  Stream<MapEntry<String, String?>> get onChanges;

  Future<String?> read(String name);

  Future<void> write(String name, String data);

  Future<void> delete(String name);
}

class BinConnection implements BinSession {
  // @override
  // BinConnection get session => this;

  final BinEngine engine;
  final _lock = Lock();

  BinConnection(this.engine);

  @override
  Stream<MapEntry<String, String?>> get onChanges => engine.onChanges;

  Future<R> runTransaction<R>(Future<R> Function(BinSession tx) body) async {
    return await _lock.synchronized(() async {
      return await BinTransaction.run(engine, body);
    });
  }

  @override
  Future<String?> read(String name) async {
    return await _lock.synchronized(() async {
      return await engine.read(name);
    });
  }

  @override
  Future<void> write(String name, String data) async {
    await _lock.synchronized(() async {
      await engine.write(name, data);
    });
  }

  @override
  Future<void> delete(String name) async {
    await _lock.synchronized(() async {
      await engine.delete(name);
    });
  }
}
