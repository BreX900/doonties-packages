import 'dart:convert';

import 'package:mekart/mekart.dart';
import 'package:uuid/enums.dart';
import 'package:uuid/v5.dart';

class CacheDocument {
  final String url;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Object? data;

  const CacheDocument({
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'data': data,
    };
  }

  factory CacheDocument.fromJson(Map<String, dynamic> map) {
    final updatedAt = map['updatedAt'] as String?;
    return CacheDocument(
      url: map['url'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt) : null,
      data: map['data'] as Object?,
    );
  }
}

abstract class CacheStore {
  static String encodeKey(Uri uri) => const UuidV5().generate(Namespace.url.value, uri.toString());

  Future<CacheDocument?> read(Uri uri);

  Future<void> write(Uri uri, Object? data);
}

class BinCacheStore<T extends Object> implements CacheStore {
  final BinConnection _engine;
  final Codec<Object?, String> _codec;

  BinCacheStore(this._engine, this._codec);

  @override
  Future<CacheDocument?> read(Uri uri) async {
    final encodedDocument = await _engine.read('cache/${CacheStore.encodeKey(uri)}.json');
    if (encodedDocument == null) return null;
    final decodedDocument = _codec.decode(encodedDocument) as Map<String, dynamic>?;
    if (decodedDocument == null) return null;
    return CacheDocument.fromJson(decodedDocument);
  }

  @override
  Future<void> write(Uri uri, Object? data) async {
    final document = CacheDocument(
      url: uri.toString(),
      createdAt: DateTime.now(),
      updatedAt: null,
      data: data,
    );
    final encodedDocument = _codec.encode(document);
    await _engine.write('cache/${CacheStore.encodeKey(uri)}.json', encodedDocument);
  }
}

class MultiCacheStore implements CacheStore {
  final CacheStore localStore;
  final CacheStore remoteStore;
  List<CacheStore> get _stores => [localStore, remoteStore];

  MultiCacheStore({required this.localStore, required this.remoteStore});

  @override
  Future<CacheDocument?> read(Uri uri) async {
    final localDocument = await localStore.read(uri);
    if (localDocument != null) return localDocument;

    final remoteDocument = await localStore.read(uri);
    if (remoteDocument == null) return null;

    await localStore.write(uri, remoteDocument.data);
    return remoteDocument;
  }

  @override
  Future<void> write(Uri uri, Object? data) async {
    await Future.wait(
      _stores.map((store) async {
        await store.write(uri, data);
      }),
    );
  }
}
