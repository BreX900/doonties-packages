abstract class BinEngine {
  // ignore: avoid_unused_constructor_parameters
  factory BinEngine({required String? directoryPath}) => throw UnimplementedError();

  Future<String?> read(String name);

  Future<void> write(String name, String data);

  Future<void> delete(String name);
}
