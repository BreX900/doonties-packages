import 'dart:io';

import 'package:shelf/shelf.dart';

class RequestLimiterMiddleware {
  final int maxRequests;
  final Duration window;

  final _requests = <String, List<DateTime>>{};

  RequestLimiterMiddleware({this.maxRequests = 60, this.window = const Duration(minutes: 1)});

  String _readAddress(Request request) {
    if (request.headers['x-forwarded-for'] case final address?) return address;
    if (request.context['shelf.io.connection_info'] case final HttpConnectionInfo info) {
      return info.remoteAddress.address;
    }
    return 'unknown';
  }

  Handler call(Handler handler) {
    return (Request request) {
      final address = _readAddress(request);

      final now = DateTime.now();

      final timestamps = _requests.putIfAbsent(address, () => []);

      // rimuove richieste fuori finestra temporale
      timestamps.removeWhere((t) => now.difference(t) >= window);

      if (timestamps.length >= maxRequests) {
        return Response(429, body: 'Too Many Requests', headers: {'Retry-After': '60'});
      }

      timestamps.add(now);

      return handler(request);
    };
  }
}
