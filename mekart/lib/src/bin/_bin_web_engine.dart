import 'package:mekart/src/bin/_bin_engine.dart' as rules_;
import 'package:web/web.dart';

class BinEngine implements rules_.BinEngine {
  // ignore: avoid_unused_constructor_parameters
  const BinEngine({required String? directoryPath});

  Storage get localStorage => window.localStorage;

  @override
  Future<String?> read(String name) async => localStorage.getItem(_getKey(name));

  @override
  Future<void> write(String name, String data) async => localStorage.setItem(_getKey(name), data);

  @override
  Future<void> delete(String name) async => localStorage.removeItem(_getKey(name));

  String _getKey(String name) => name;
}
