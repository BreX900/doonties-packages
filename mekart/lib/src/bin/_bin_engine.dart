abstract class BinEngine {
  static late BinEngine instance;

  factory BinEngine({
    // ignore: avoid_unused_constructor_parameters
    required String? directoryPath,
  }) =>
      throw UnimplementedError();

  Future<String?> read(String name);

  Future<void> write(String name, String data);

  Future<void> delete(String name);
}
