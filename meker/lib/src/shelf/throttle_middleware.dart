import 'package:shelf/shelf.dart';

class const ThrottleMiddleware() {
  Handler call(Handler handler) {
    return (request) async {
      final response = await handler(request);
      await Future.pause(const Duration(milliseconds: 300));
      return response;
    };
  }
}
