import 'package:mekart/src/bin/_bin_engine.dart' as rules_;
import 'package:web/web.dart';

class BinEngine implements rules_.BinEngine {
  static late BinEngine instance;

  // ignore: avoid_unused_constructor_parameters
  const BinEngine({required String? directoryPath});

  Storage get _localStorage => window.localStorage;

  @override
  Future<String?> read(String name) async => _localStorage.getItem(_getKey(name));

  @override
  Future<void> write(String name, String data) async => _localStorage.setItem(_getKey(name), data);

  @override
  Future<void> delete(String name) async => _localStorage.removeItem(_getKey(name));

  String _getKey(String name) => name;
}
