import 'package:mekart/src/bin/bin_engine.dart';
import 'package:web/web.dart';

BinEngine createBinEngine({required String? directoryPath}) => const _BinWebEngine();

class _BinWebEngine implements BinEngine {
  // ignore: avoid_unused_constructor_parameters
  const _BinWebEngine();

  Storage get _localStorage => window.localStorage;

  @override
  Future<String?> read(String name) async => _localStorage.getItem(_getKey(name));

  @override
  Future<void> write(String name, String data) async => _localStorage.setItem(_getKey(name), data);

  @override
  Future<void> delete(String name) async => _localStorage.removeItem(_getKey(name));

  String _getKey(String name) => name;
}
