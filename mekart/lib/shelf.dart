import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

enum _CacheVisibility { public, private, noCache, noStore }

/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control
class const CacheMiddleware._({
  required final _CacheVisibility _visibility,
  required final Duration? maxAge,
  final bool mustRevalidate = false,
  final bool immutable = false,
  required final List<String> includedPaths,
  required final List<String> excludedPaths,
}) {
  const CacheMiddleware.public({
    Duration? maxAge,
    bool immutable = false,
    List<String> includedPaths = const ['/**'],
    List<String> excludedPaths = const [],
  }) : this._(
         visibility: .public,
         maxAge: maxAge,
         immutable: immutable,
         includedPaths: includedPaths,
         excludedPaths: excludedPaths,
       );

  const CacheMiddleware.private({
    bool immutable = false,
    List<String> includedPaths = const ['/**'],
    List<String> excludedPaths = const [],
  }) : this._(
         visibility: .private,
         maxAge: null,
         immutable: immutable,
         includedPaths: includedPaths,
         excludedPaths: excludedPaths,
       );

  const CacheMiddleware.noCache({
    bool immutable = false,
    List<String> includedPaths = const ['/**'],
    List<String> excludedPaths = const [],
  }) : this._(
         visibility: .noCache,
         maxAge: Duration.zero,
         immutable: immutable,
         includedPaths: includedPaths,
         excludedPaths: excludedPaths,
       );

  const CacheMiddleware.noStore({
    List<String> includedPaths = const ['/**'],
    List<String> excludedPaths = const [],
  }) : this._(
         visibility: .noStore,
         maxAge: Duration.zero,
         immutable: false,
         includedPaths: includedPaths,
         excludedPaths: excludedPaths,
       );

  Handler call(Handler handler) {
    final headers = _buildHeaders();
    final included = includedPaths.map(Glob.new).toList();
    final excluded = excludedPaths.map(Glob.new).toList();

    return (request) async {
      final path = '/${request.url}';

      if (!included.any((e) => e.matches(path))) return handler(request);
      if (excluded.any((e) => e.matches(path))) return handler(request);

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
      timestamps.removeWhere((t) => now.difference(t) >= window);

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

abstract final class Handlers {
  static Handler webApp({required String path}) {
    const mainFiles = ['/', '/index.html', '/flutter_bootstrap.js'];
    final pipeline = const Pipeline()
        .addMiddleware(const CacheMiddleware.noStore(includedPaths: mainFiles))
        .addMiddleware(const CacheMiddleware.public(immutable: true, excludedPaths: mainFiles))
        .addMiddleware(const MultithreadMiddleware());

    final directoryHandler = createStaticHandler(path, defaultDocument: 'index.html');

    return pipeline.addHandler((request) async {
      final response = await directoryHandler(request);
      if (response.statusCode != 404) return response;

      return createFileHandler('$path/index.html', url: request.url.path).call(request);
    });
  }
}
