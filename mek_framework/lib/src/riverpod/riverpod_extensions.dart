import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RefreshAndInvalidateAncestorsWidgetRefExtension on WidgetRef {
  void refreshAndInvalidateAncestors(ProviderBase<Object?> provider) =>
      ProviderScope.containerOf(context, listen: false).refreshAndInvalidateAncestors(provider);
}

extension InvalidateFromProviderContainerExtension on ProviderContainer {
  void refreshAndInvalidateAncestors<T>(ProviderBase<Object?> provider) {
    final element = readProviderElement(provider);
    final visitor = _createVisitor((element) => element.invalidateSelf());
    visitor(element);

    // ignore: invalid_use_of_protected_member, invalid_use_of_internal_member
    element.flush();
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
