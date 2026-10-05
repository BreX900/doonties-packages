import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:mek/src/storage/_file_storage.dart'
    if (dart.library.html) 'package:mek/src/storage/_web_storage.dart'
    as platform;
import 'package:rivertion/rivertion.dart';

part 'lazy_value_storage.dart';
part 'memory_storage.dart';
part 'storage_codec.dart';
part 'value_storage.dart';

mixin StorageBase<T> {
  FutureOr<T> read(String key);

  Future<void> write(String key, T value);

  void dispose();
}

mixin Storage<T> on StorageBase<T> {
  // getApplicationDocumentsDirectory
  static Future<Storage<Object?>> create(String? directoryPath) =>
      platform.createLocalStorage(directoryPath);

  ValueObservable<T> watch(String key);

  ValueStorage<R> value<R>(String key, StorageCodec<R, T> codec) =>
      _ValueStorageWithCodec(this, key, codec);

  @override
  T read(String key);

  Future<void> delete(String key);
}

mixin LazyStorage<T> on StorageBase<T> {
  // getApplicationDocumentsDirectory
  static LazyStorage<Object?> create(String? directoryPath) =>
      platform.createLocalLazyStorage(directoryPath);

  LazyValueStorage<T> value(String key) => _LazyValueStorageWithCodec<T, T>(this, key, .none<T>());

  Stream<T> watch(String key);

  @override
  Future<T> read(String key);

  Future<void> delete(String key);
}
