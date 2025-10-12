import 'package:mekart/src/bin/_bin_io_engine.dart'
    if (dart.library.html) 'package:mekart/src/bin/_bin_web_engine.dart'
    as platform;

abstract interface class BinEngine {
  static late BinEngine instance;

  factory BinEngine({required String? directoryPath}) =>
      platform.createBinEngine(directoryPath: directoryPath);

  Stream<MapEntry<String, String?>> get onChanges;

  Future<String?> read(String name);

  Future<void> write(String name, String data);

  Future<void> delete(String name);
}
