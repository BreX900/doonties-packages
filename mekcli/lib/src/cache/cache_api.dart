import 'package:mekcli/src/cache/cache_store.dart';
import 'package:mekcli/src/cli_utils.dart';

const String _validityExtraKey = 'cache.validity';
const String _isFromExtraKey = 'cache.isFromCache';

class CacheResponse {
  final Map<String, dynamic> extra;
  final Object? data;

  CacheResponse._(this.data) : extra = {_isFromExtraKey: true};
}

class CacheApi {
  final CacheStore store;

  CacheApi(this.store);

  static Map<String, dynamic> extra([DateTime? validity]) => {
    _validityExtraKey: validity ?? DateTime(0),
  };

  Future<CacheResponse?> read(Map<String, dynamic> extra, Uri uri) async {
    final validity = extra[_validityExtraKey] as DateTime?;
    if (validity == null) {
      lg.finest('$uri: Cache skipped');
      return null;
    }

    final document = await store.read(uri);
    if (document == null) {
      lg.finer('$uri: Cache missed. Validity: $validity');
      return null;
    }

    final createdAt = document.updatedAt ?? document.createdAt;
    if (createdAt.isBefore(validity)) {
      lg.finer('$uri: Cache invalid. Validity: $validity cache: $createdAt');
      return null;
    }

    lg.finest('$uri: Cache hit. Validity: $validity cache: $createdAt');
    return CacheResponse._(document.data);
  }

  Future<void> write(
    Map<String, dynamic> requestExtra,
    Map<String, dynamic> extra,
    Uri uri,
    Object? data,
  ) async {
    final validity = requestExtra[_validityExtraKey] as DateTime?;
    final isFromCache = extra[_isFromExtraKey] as bool? ?? false;

    if (validity != null && !isFromCache) {
      lg.finer('$uri: Fill cache.');
      await store.write(uri, data);
    }
  }
}
