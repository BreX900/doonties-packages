import 'dart:io';

import 'package:shelf/shelf.dart';

enum _CacheVisibility { public, private, noCache, noStore }

/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control
class const CacheMiddleware._({
  required final _CacheVisibility _visibility,
  final Duration? maxAge,
  final bool mustRevalidate = false,
  final bool immutable = false,
}) {
  const CacheMiddleware.public({Duration? maxAge, bool immutable = false})
    : this._(visibility: .public, maxAge: maxAge, immutable: immutable);

  const CacheMiddleware.private({bool immutable = false})
    : this._(visibility: .private, maxAge: null, immutable: immutable);

  const CacheMiddleware.noCache({bool immutable = false})
    : this._(visibility: .noCache, maxAge: Duration.zero, immutable: immutable);

  const CacheMiddleware.noStore()
    : this._(visibility: .noStore, maxAge: Duration.zero, immutable: false);

  static const CacheMiddleware staticFiles = .public(immutable: true);

  Handler call(Handler handler) {
    final headers = _buildHeaders();
    return (request) async {
      final response = await handler(request);
      return response.change(headers: {...response.headers, ...headers});
    };
  }

  Map<String, String> _buildHeaders() {
    return <String, String>{
      'Cache-Control': _buildCacheControl(),
      if (maxAge case final maxAge?) 'Expires': HttpDate.format(DateTime.now().toUtc().add(maxAge)),
      if (_visibility == .noCache) 'Pragma': 'no-cache',
    };
  }

  String _buildCacheControl() {
    return <String>[
      switch (_visibility) {
        .public => 'public',
        .private => 'private',
        .noCache => 'no-cache',
        .noStore => 'no-store',
      },
      if (maxAge case final age?) 'max-age=${age.inSeconds}',
      if (mustRevalidate) 'must-revalidate',
      if (immutable) 'immutable',
    ].join(', ');
  }
}

class const CorsMiddleware({required final String? origin}) {
  Handler call(Handler handler) {
    return (request) async {
      final requestOrigin = request.headers['origin'];
      if (requestOrigin == null) return handler(request);

      final headers = {
        'Access-Control-Allow-Origin': (origin ?? request.headers['origin'])!,
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Max-Age': '86400',
        'Access-Control-Allow-Credentials': 'true',
      };
      if (request.method == 'OPTIONS') return Response.ok('', headers: headers);

      final response = await handler(request);

      return response.change(headers: {...headers, ...response.headers});
    };
  }
}

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
      timestamps.removeWhere((t) => now.difference(t) < window);

      if (timestamps.length >= maxRequests) {
        return Response(429, body: 'Too Many Requests', headers: {'Retry-After': '60'});
      }

      timestamps.add(now);

      return handler(request);
    };
  }
}

// Flutter Web: Skwasm uses multi-threading and web workers for better performance, but your page needs to be cross-origin isolated to support multi-threading. Skwasm will run in single-threaded mode.
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

class const ThrottleMiddleware() {
  Handler call(Handler handler) {
    return (request) async {
      final response = await handler(request);
      await Future.pause(const Duration(milliseconds: 300));
      return response;
    };
  }
}
