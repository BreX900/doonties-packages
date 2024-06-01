import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/auto_dispose_extension.dart';

extension SubscribeWidgetRefExtension on WidgetRef {
  void subscribe<T>(
    ProviderListenable<T> provider,
    void Function(T data) listener, {
    bool Function(T? previous, T next)? when,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    listen(onError: onError, provider, (previous, next) {
      if (!(when?.call(previous, next) ?? true)) return;
      listener(next);
    });
  }

  ProviderSubscription<T> subscribeManual<T>(
    ProviderListenable<T> provider,
    void Function(T data) listener, {
    bool Function(T? previous, T next)? when,
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) {
    return listenManual(fireImmediately: true, onError: onError, provider, (previous, next) {
      if (!(when?.call(previous, next) ?? true)) return;
      listener(next);
    });
  }

  ProviderSubscription<void> subscribeManualStream<T>(
    Stream<T> stream,
    void Function(T event) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return onDispose(stream.listen(listener, onError: onError).cancel);
  }
}
