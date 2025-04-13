import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RefreshAndInvalidateAncestorsWidgetRefExtension on WidgetRef {
  void invalidateWithAncestors(ProviderBase<Object?> provider) {
    final container = ProviderScope.containerOf(context, listen: false);
    container.invalidateAncestors(provider);
    container.invalidate(provider);
  }
}

extension InvalidateFromProviderContainerExtension on ProviderContainer {
  void invalidateAncestors<T>(ProviderBase<Object?> provider) {
    if (!exists(provider)) return;

    final element = readProviderElement(provider);
    final elements = <ProviderElementBase<Object?>>[];

    void visitor(ProviderElementBase<Object?> element) {
      if (_checkCanInvalidate(element)) elements.add(element);

      element.visitAncestors(visitor);
    }

    visitor(element);
  }

  bool _checkCanInvalidate(ProviderElementBase<Object?> element) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_internal_member
    final state = element.getState();
    if (state == null || !state.hasState) return true;

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
