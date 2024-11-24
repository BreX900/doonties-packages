import 'dart:async';

import 'package:mekart/src/bin/bin_engine.dart';
import 'package:web/web.dart';

BinEngine createBinEngine({required String? directoryPath}) => _BinWebEngine();

class _BinWebEngine implements BinEngine {
  final _controller = StreamController<MapEntry<String, String?>>.broadcast(sync: true);

  @override
  Stream<MapEntry<String, String?>> get onChanges => _controller.stream;

  Storage get _localStorage => window.localStorage;

  @override
  Future<String?> read(String name) async => _localStorage.getItem(_getKey(name));

  @override
  Future<void> write(String name, String data) async {
    _localStorage.setItem(_getKey(name), data);
    _controller.add(MapEntry(name, data));
  }

  @override
  Future<void> delete(String name) async => _localStorage.removeItem(_getKey(name));

  String _getKey(String name) => name;
}
