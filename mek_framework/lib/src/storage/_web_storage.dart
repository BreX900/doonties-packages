import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:mek/src/storage/storage.dart';
import 'package:rivertion/rivertion.dart';
import 'package:web/web.dart' as web;

web.Storage get _localStorage => web.window.localStorage;

Future<Storage<Object?>> createLocalStorage(String? directoryPath) async {
  final data = <String, Object?>{};
  for (var index = 0; index < _localStorage.length; index++) {
    final key = _localStorage.key(index);
    if (key == null || !key.startsWith(_WebStorage.prefix)) continue;

    final value = _localStorage.getItem(key.replaceFirst(_WebStorage.prefix, ''));
    data[key] = value != null ? jsonDecode(value) : null;
  }
  return _WebStorage._(data);
}

LazyStorage<Object?> createLocalLazyStorage(String? directoryPath) => _WebLazyStorage._();

class _WebStorage extends StateNotifier<Map<String, Object?>>
    with StorageBase<Object?>, Storage<Object?> {
  static const String prefix = '_cached_.';

  _WebStorage._(super._state);

  @override
  ValueObservable<dynamic> watch(String key) => observable.select((data) => data[key]);

  @override
  Object? read(String key) => state[key];

  @override
  Future<void> write(String key, Object? value) async {
    state = {...state, key: value};
    _localStorage.setItem('$prefix$key', jsonEncode(value));
  }

  @override
  Future<void> delete(String key) async {
    state = {...state}..remove(key);
    _localStorage.removeItem('$prefix$key');
  }

  @override
  Future<void> clean() async {
    state = {};
    for (final key in state.keys) {
      _localStorage.removeItem('$prefix$key');
    }
  }
}

class _WebLazyStorage with StorageBase<String?>, LazyStorage<String?> {
  static const String prefix = '_lazy_.';
  final _controller = StreamController<MapEntry<String, String?>>.broadcast();

  _WebLazyStorage._();

  @override
  Stream<String?> watch(String key) =>
      _controller.stream.where((entry) => entry.key == key).map((entry) => entry.value);

  @override
  Future<String?> read(String key) async {
    return _localStorage.getItem('$prefix$key');
  }

  @override
  Future<void> write(String key, String? value) async {
    if (value != null) {
      _localStorage.setItem('$prefix$key', value);
      _controller.add(MapEntry(key, value));
    } else {
      await delete(key);
    }
  }

  @override
  Future<void> delete(String key) async {
    _localStorage.removeItem('$prefix$key');
    _controller.add(MapEntry(key, null));
  }

  @override
  Future<void> clean() async {
    for (var index = 0; index < _localStorage.length; index++) {
      final key = _localStorage.key(index);
      if (key == null || !key.startsWith(prefix)) continue;
      _localStorage.removeItem(key);
    }
  }

  @override
  void dispose() => _controller.close();
}
