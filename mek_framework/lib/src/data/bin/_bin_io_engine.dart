import 'dart:io';

import 'package:mek/src/data/bin/_bin_engine.dart' as rules_;
import 'package:path_provider/path_provider.dart';

class BinEngine implements rules_.BinEngine {
  const BinEngine();

  static BinEngine instance = const BinEngine();

  @override
  Future<String?> read(String name) async {
    final file = await _get(name);
    if (!file.existsSync()) return null;
    return await file.readAsString();
  }

  @override
  Future<void> write(String name, String data) async {
    final file = await _get(name);
    if (!file.parent.existsSync()) await file.parent.create(recursive: true);
    await file.writeAsString(data, flush: true);
  }

  @override
  Future<void> delete(String name) async {
    final file = await _get(name);
    if (!file.existsSync()) return;
    await file.delete();
  }

  Future<File> _get(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$name');
  }
}
