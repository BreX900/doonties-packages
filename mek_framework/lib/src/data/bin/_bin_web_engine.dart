// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:mek/src/data/bin/_bin_engine.dart' as rules_;

class BinEngine implements rules_.BinEngine {
  const BinEngine();

  static BinEngine instance = const BinEngine();

  html.Storage get localStorage => html.window.localStorage;

  @override
  Future<String?> read(String prefix, String name) async => localStorage[_get(prefix, name)];

  @override
  Future<void> write(String prefix, String name, String data) async =>
      localStorage[_get(prefix, name)] = data;

  @override
  Future<void> delete(String prefix, String name) async => localStorage.remove(_get(prefix, name));

  String _get(String prefix, String name) => prefix.isEmpty ? name : '$prefix#$name';
}
