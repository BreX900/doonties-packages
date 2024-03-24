import 'package:flutter/cupertino.dart';

class Crashlytics {
  const Crashlytics._();

  static const Crashlytics none = Crashlytics._();

  Future<void> log(String message) async {}

  Future<void> reportError({
    required String? message,
    required Object error,
    StackTrace? stackTrace,
  }) async {}

  Future<void> reportFlutterError({
    required String? message,
    required FlutterErrorDetails error,
  }) async {}
}
