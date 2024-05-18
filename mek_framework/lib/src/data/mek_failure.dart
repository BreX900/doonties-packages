abstract class MekFailure implements Exception {
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}
