abstract class BinEngine {
  factory BinEngine() => throw UnimplementedError();

  static BinEngine get instance => throw UnimplementedError();
  static BinEngine get engine => throw UnimplementedError();
  static set engine(BinEngine engine) => throw UnimplementedError();

  Future<String?> read(String prefix, String name);

  Future<void> write(String prefix, String name, String data);

  Future<void> delete(String prefix, String name);
}
