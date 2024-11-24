import 'package:mekart/src/bin/bin_engine.dart';

abstract class BinEngineBase implements BinEngine {
  BinEngine? _instance;

  Future<String?> getDirectoryPath();

  @override
  Stream<MapEntry<String, String?>> get onChanges async* {
    final instance = _instance ??= await _createInstance();
    yield* instance.onChanges;
  }

  @override
  Future<String?> read(String name) async {
    final instance = _instance ??= await _createInstance();
    return instance.read(name);
  }

  @override
  Future<void> write(String name, String data) async {
    final instance = _instance ??= await _createInstance();
    return instance.write(name, data);
  }

  @override
  Future<void> delete(String name) async {
    final instance = _instance ??= await _createInstance();
    return instance.delete(name);
  }

  Future<BinEngine> _createInstance() async {
    final directoryPath = await getDirectoryPath();
    return BinEngine(directoryPath: directoryPath);
  }
}
