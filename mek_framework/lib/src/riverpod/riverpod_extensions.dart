// ignore_for_file: invalid_use_of_internal_member

// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart';

extension RefreshAndInvalidateAncestorsWidgetRefExtension on WidgetRef {
  void invalidateWithAncestors($ProviderBaseImpl<Object?> provider) {
    final container = ProviderScope.containerOf(context, listen: false);
    container.invalidateAncestors(provider);
    container.invalidate(provider);
  }
}

extension InvalidateFromProviderContainerExtension on ProviderContainer {
  void invalidateAncestors<T>($ProviderBaseImpl<Object?> provider) {
    if (!exists(provider)) return;

    final element = pointerManager.readElement(provider);
    final elements = <ProviderElement<dynamic, dynamic>>[];

    void visitor(ProviderElement<dynamic, dynamic>? element) {
      if (element == null) return;

      if (_checkCanInvalidate(element)) elements.add(element);

      element.visitAncestors(visitor);
    }

    visitor(element);

    for (final element in elements) {
      element.invalidateSelf(asReload: true);
    }
  }

  bool _checkCanInvalidate(ProviderElement<dynamic, dynamic> element) {
    final value = element.stateResult()?.value;
    if (value == null || value is! AsyncValue) return true;

    if (element.provider is $FutureProviderElement) return true;
    if (element is $StreamProviderElement) return value.hasError;

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
