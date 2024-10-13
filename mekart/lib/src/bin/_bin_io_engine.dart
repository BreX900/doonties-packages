import 'dart:io';

import 'package:mekart/src/bin/bin_engine.dart';

BinEngine createBinEngine({required String? directoryPath}) =>
    _BinIoEngine(directoryPath: directoryPath);

class _BinIoEngine implements BinEngine {
  final String _directoryPath;

  _BinIoEngine({required String? directoryPath}) : _directoryPath = directoryPath!;

  @override
  Future<String?> read(String name) async {
    final file = _get(name);
    if (!file.existsSync()) return null;
    return await file.readAsString();
  }

  @override
  Future<void> write(String name, String data) async {
    final file = _get(name);
    if (!file.parent.existsSync()) await file.parent.create(recursive: true);
    await file.writeAsString(data, flush: true);
  }

  @override
  Future<void> delete(String name) async {
    final file = _get(name);
    if (!file.existsSync()) return;
    await file.delete();
  }

  File _get(String name) => File('$_directoryPath/$name');
}
