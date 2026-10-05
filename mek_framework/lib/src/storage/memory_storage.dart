part of 'storage.dart';

class MemoryStorage extends StateNotifier<Map<String, Object?>>
    with StorageBase<Object?>, Storage<Object?> {
  MemoryStorage() : super({});

  @override
  ValueObservable<dynamic> watch(String key) => observable.select((data) => data[key]);

  @override
  Object? read(String key) => state[key];

  @override
  Future<void> write(String key, Object? value) async {
    state = {...state, key: value};
  }

  @override
  Future<void> delete(String key) async {
    state = {...state, key: null};
  }
}
