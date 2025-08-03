import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';

extension FutureOfDataAsyncProviderExtension<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<FutureOr<T>> get futureOfData => _ProviderListenable(this);
}

class _ProviderListenable<T> with ProviderListenable<FutureOr<T>> {
  final ProviderListenable<AsyncValue<T>> source;

  _ProviderListenable(this.source);

  @override
  ProviderSubscription<FutureOr<T>> addListener(
    Node node,
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    var fire = fireImmediately;
    AsyncData<T>? current;

    final subscription = source.addListener(
      node,
      (a, b) {
        final previous = a?.asData;
        final next = b.asData;

        current ??= previous?.asData;
        if (next != null) {
          if (fire && current != next) listener(current?.requireValue, next.requireValue);
          current = next;
        }

        fire = true;
      },
      onError: onError,
      onDependencyMayHaveChanged: onDependencyMayHaveChanged,
      fireImmediately: true,
    );
    return _Subscription(node, () => read(node), subscription.close);
  }

  @override
  FutureOr<T> read(Node node) {
    final state = source.read(node);
    if (state.hasValue) return state.requireValue;

    final completer = Completer<T>.sync();
    late final ProviderSubscription<AsyncValue<T>> subscription;
    subscription = source.addListener(
      node,
      (_, state) {
        if (!state.hasValue) return;
        completer.complete(state.requireValue);
        subscription.close();
      },
      onError: null,
      onDependencyMayHaveChanged: null,
      fireImmediately: true,
    );
    return completer.future;
  }
}

class _Subscription<T> extends ProviderSubscription<T> {
  final T Function() reader;
  final void Function() listenerRemover;

  _Subscription(super.source, this.reader, this.listenerRemover);

  @override
  T read() => reader();

  @override
  void close() {
    super.close();
    listenerRemover();
  }
}
