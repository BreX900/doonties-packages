import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/typedefs.dart';

extension InvalidateFromProviderContainerExtension on ProviderContainer {
  /// Invalidate all ancestors providers from [provider] and flush it
  void invalidateAncestors(ProviderBase<Object?> provider) {
    if (!exists(provider)) return;

    final element = readProviderElement(provider);

    final dirtyParents = <ProviderElementBase<Object?>>{};
    final dirtyChildren = <ProviderElementBase<Object?>>{};

    bool visitor(ProviderElementBase<Object?> element) {
      if (element is! ProviderElementBase<AsyncValue>) return false;
      if (!_checkCanInvalidate(element)) return false;

      var isInvalidated = false;
      element.visitAncestors((element) {
        final isParentInvalidated = visitor(element);
        if (isParentInvalidated) isInvalidated = true;
      });

      if (isInvalidated) {
        dirtyParents.remove(element);
        dirtyChildren.add(element);
      }
      if (!dirtyChildren.contains(element)) dirtyParents.add(element);

      return true;
    }

    visitor(element);

    for (final element in dirtyParents) {
      element.invalidateSelf();
    }

    // ignore: invalid_use_of_internal_member
    element.flush();
  }

  void invalidateFrom(ProviderBase<Object?> provider) {
    if (!exists(provider)) return;

    final element = readProviderElement(provider);
    final visitor = _createVisitor((element) => element.invalidateSelf());
    visitor(element);

    // ignore: invalid_use_of_internal_member
    element.flush();
  }

  bool shouldInvalidate(ProviderBase<Object?> provider) {
    final element = readProviderElement(provider);

    var shouldInvalidate = false;
    final visitor = _createVisitor((element) {
      shouldInvalidate = true;
    });
    visitor(element);
    return shouldInvalidate;
  }

  void Function(ProviderElementBase<Object?> element) _createVisitor(
    void Function(ProviderElementBase<AsyncValue>) visitor,
  ) {
    return (ProviderElementBase<Object?> element) {
      if (element is! ProviderElementBase<AsyncValue>) return;
      if (!_checkCanInvalidate(element)) return;

      visitor(element);

      element.visitAncestors(_createVisitor(visitor));
    };
  }

  bool _checkCanInvalidate(ProviderElementBase<AsyncValue<Object?>> element) {
    if (element is FutureProviderElement) return true;
    // ignore: invalid_use_of_protected_member, invalid_use_of_internal_member
    if (element is StreamProviderElement) return element.requireState.hasError;
    return false;
  }
}

extension ProviderListenableExtensions<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<AsyncValue<R>> selectData<R>(R Function(T value) mapper) =>
      select((value) => value.whenData<R>(mapper));
}

extension ListenAsyncWidgetRefExtension on WidgetRef {
  @Deprecated('')
  void listenAsyncValue<T>(
    ProviderListenable<AsyncValue<T>> provider, {
    ListenerCondition<AsyncValue<T>>? when,
    void Function()? loading,
    void Function(Object error, StackTrace stackTrace)? error,
    void Function(T data)? data,
  }) {
    listen(provider, (previous, next) {
      if (when != null && !when(previous!, next)) return;
      next.whenOrNull<void>(
        loading: loading,
        error: error,
        data: data,
      );
    });
  }

  @Deprecated('')
  void listenManualAsyncValue<T>(
    ProviderListenable<AsyncValue<T>> provider, {
    bool fireImmediately = false,
    ListenerCondition<AsyncValue<T>>? when,
    void Function()? loading,
    void Function(Object error, StackTrace stackTrace)? error,
    void Function(T data)? data,
  }) {
    listenManual(fireImmediately: fireImmediately, provider, (previous, next) {
      if (when != null && !when(previous!, next)) return;
      next.whenOrNull<void>(
        loading: loading,
        error: error,
        data: data,
      );
    });
  }

  void listenManualFuture<T>(
    ProviderListenable<Future<T>> provider,
    void Function(T data) listener, {
    bool fireImmediately = false,
  }) {
    listenManual(fireImmediately: fireImmediately, provider, (previous, next) async {
      listener(await next);
    });
  }
}
