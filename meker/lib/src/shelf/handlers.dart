import 'package:meker/src/shelf/cache_middleware.dart';
import 'package:meker/src/shelf/multithread_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

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
