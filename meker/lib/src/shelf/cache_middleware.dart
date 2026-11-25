import 'dart:io';

import 'package:glob/glob.dart';
import 'package:shelf/shelf.dart';

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
