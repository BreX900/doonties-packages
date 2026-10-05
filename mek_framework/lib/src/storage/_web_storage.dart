import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:mek/src/storage/storage.dart';
import 'package:rivertion/rivertion.dart';
import 'package:web/web.dart' as web;

Future<Storage<Object?>> createLocalStorage(String? directoryPath) async {
  final data = <String, Object?>{};
  for (var index = 0; index < web.window.localStorage.length; index++) {
    final key = web.window.localStorage.key(index);
    if (key == null) continue;
    data[key] = web.window.localStorage.getItem(key);
  }
  return _WebStorage._(data);
}

LazyStorage<Object?> createLocalLazyStorage(String? directoryPath) => _WebLazyStorage._();

web.Storage get _localStorage => web.window.localStorage;

class _WebStorage extends StateNotifier<Map<String, Object?>>
    with StorageBase<Object?>, Storage<Object?> {
  _WebStorage._(super._state);

  @override
  ValueObservable<dynamic> watch(String key) => observable.select((data) => data[key]);

  @override
  Object? read(String key) => state[key];

  @override
  Future<void> write(String key, Object? value) async {
    state = {...state, key: value};
    _localStorage.setItem(key, jsonEncode(value));
  }

  @override
  Future<void> delete(String key) async {
    state = {...state, key: null};
    _localStorage.removeItem(key);
  }
}

class _WebLazyStorage with StorageBase<String?>, LazyStorage<String?> {
  final _controller = StreamController<MapEntry<String, String?>>.broadcast();

  _WebLazyStorage._();

  @override
  Stream<String?> watch(String key) =>
      _controller.stream.where((entry) => entry.key == key).map((entry) => entry.value);

  @override
  Future<String?> read(String key) async {
    return _localStorage.getItem(key);
  }

  @override
  Future<void> write(String key, String? value) async {
    if (value != null) {
      _localStorage.setItem(key, value);
      _controller.add(MapEntry(key, value));
    } else {
      _localStorage.removeItem(key);
      _controller.add(MapEntry(key, null));
    }
  }

  @override
  Future<void> delete(String key) async {
    _localStorage.removeItem(key);
    _controller.add(MapEntry(key, null));
  }

  @override
  void dispose() => _controller.close();
}
