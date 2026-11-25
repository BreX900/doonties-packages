// Flutter Web: Skwasm uses multi-threading and web workers for better performance, but your page needs to be cross-origin isolated to support multi-threading. Skwasm will run in single-threaded mode.
import 'package:shelf/shelf.dart';

class const MultithreadMiddleware() {
  Handler call(Handler handler) {
    return (request) async {
      final response = await handler(request);

      return response.change(
        headers: {
          ...response.headers,
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
        },
      );
    };
  }
}
