import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/legacy.dart';
import 'package:mek/src/storage/storage.dart';
import 'package:rivertion/rivertion.dart';

Future<Storage<Object?>> createLocalStorage(String? directoryPath) async {
  final file = File('$directoryPath/_preferences.json');
  if (!file.existsSync()) return _FileStorage._(file, {});

  final content = await file.readAsString();
  final data = jsonDecode(content) as Map<String, Object?>;

  return _FileStorage._(file, data);
}

LazyStorage<Object?> createLocalLazyStorage(String? directoryPath) {
  final storagesDirectory = Directory('$directoryPath/storages');
  if (!storagesDirectory.existsSync()) storagesDirectory.createSync(recursive: true);

  return _FileLazyStorage._(storagesDirectory);
}

class _FileStorage extends StateController<Map<String, Object?>>
    with StorageBase<Object?>, Storage<Object?> {
  final File _file;

  _FileStorage._(this._file, super._state);

  @override
  ValueObservable<dynamic> watch(String key) => observable.select((data) => data[key]);

  @override
  Object? read(String key) => state[key];

  @override
  Future<void> write(String key, Object? value) async {
    state = {...state, key: value};
    _file.writeAsStringSync(jsonEncode(state));
  }

  @override
  Future<void> delete(String key) async {
    state = {...state, key: null};
    _file.writeAsStringSync(jsonEncode(state));
  }
}

class _FileLazyStorage with StorageBase<String?>, LazyStorage<String?> {
  final Directory _directory;
  final _controller = StreamController<MapEntry<String, String?>>.broadcast();

  _FileLazyStorage._(this._directory);

  @override
  Stream<String?> watch(String key) =>
      _controller.stream.where((entry) => entry.key == key).map((entry) => entry.value);

  @override
  Future<String?> read(String key) async {
    if (!_getFile(key).existsSync()) return null;

    return await _getFile(key).readAsString();
  }

  @override
  Future<void> write(String key, String? value) async {
    if (value != null) {
      await _getFile(key).writeAsString(value);
      _controller.add(MapEntry(key, value));
    } else {
      await _getFile(key).delete();
      _controller.add(MapEntry(key, null));
    }
  }

  @override
  Future<void> delete(String key) async {
    if (_getFile(key).existsSync()) await _getFile(key).delete();
    _controller.add(MapEntry(key, null));
  }

  @override
  void dispose() => _controller.close();

  File _getFile(String name) => File('${_directory.path}/$name.json');
}
