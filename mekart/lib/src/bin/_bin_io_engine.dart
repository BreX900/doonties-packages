import 'dart:io';

import 'package:mekart/src/bin/_bin_engine.dart' as rules_;

class BinEngine implements rules_.BinEngine {
  static late BinEngine instance;

  final String directoryPath;

  BinEngine({required this.directoryPath});

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

  File _get(String name) => File('$directoryPath/$name');
}
