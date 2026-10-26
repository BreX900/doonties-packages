import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';

abstract class MutationRef {
  final ProviderContainer _ref;
  var _dependencies = <ProviderListenable<Object?>, ProviderSubscription>{};
  var _mounted = false;

  MutationRef(this._ref);

  bool get mounted => _mounted;

  bool exists(ProviderBase<Object?> provider) {
    debugEnsureIsMounted();
    return _ref.exists(provider);
  }

  T read<T>(ProviderListenable<T> provider) {
    debugEnsureIsMounted();
    return _subscribe(provider).read();
  }

  T refresh<T>(Refreshable<T> provider) {
    debugEnsureIsMounted();
    final result = _ref.refresh(provider);
    _subscribe(provider);
    return result;
  }

  void invalidate(ProviderOrFamily provider, {bool asReload = false}) {
    debugEnsureIsMounted();
    _ref.invalidate(provider, asReload: asReload);
  }

  Future<T> readOrRefresh<T>(Refreshable<Future<T>> refreshable) async {
    try {
      return await read(refreshable);
    } on Object {
      return await refresh(refreshable);
    }
  }

  void updateProgress(double value);

  ProviderSubscription<T> _subscribe<T>(ProviderListenable<T> provider) {
    return _dependencies.putIfAbsent(provider, () => _ref.listen(provider, (_, _) {}))
        as ProviderSubscription<T>;
  }

  @protected
  void debugEnsureIsMounted() {
    assert(!mounted, 'MutationRef is not mounted!');
  }

  @protected
  @mustCallSuper
  void dispose() {
    _mounted = false;
    for (final subscription in _dependencies.values) {
      subscription.close();
    }
    _dependencies = const {};
  }
}
