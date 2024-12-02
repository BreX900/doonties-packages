import 'dart:async';

import 'package:mekart/mekart.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';

abstract class SourceProviderListenable<S, T> extends _ProviderListenableBase<T> {
  final S source;

  const SourceProviderListenable(this.source);

  T get state;

  bool updateShouldNotify(T prev, T next) => true;

  void Function() listen(void Function(T state) listener);

  @override
  T read(Node node) => state;

  @override
  ProviderSubscription<T> addListener(
    Node node,
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    var current = state;
    final subscription = listen((next) {
      final prev = current;
      current = next;

      if (updateShouldNotify(prev, next)) listener(prev, next);
    });

    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, current);

    return _Subscription(node, this, subscription);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceProviderListenable &&
          runtimeType == other.runtimeType &&
          source == other.source;

  @override
  int get hashCode => Object.hash(runtimeType, source);
}

class _ProviderListenableSelector<T, R> extends _ProviderListenableBase<R> {
  final ProviderListenable<T> listenable;
  final R Function(T state) selector;

  const _ProviderListenableSelector(this.listenable, this.selector);

  @override
  R read(Node node) => selector(listenable.read(node));

  @override
  ProviderSubscription<R> addListener(
    Node node,
    void Function(R? previous, R next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    late R current;
    final subscription = listenable.addListener(
      node,
      (_, next) {
        final prev = current;
        current = selector(next);

        if (!iEquality.equals(prev, next)) listener(prev, current);
      },
      onError: onError,
      onDependencyMayHaveChanged: onDependencyMayHaveChanged,
      fireImmediately: false,
    );
    current = selector(subscription.read());
    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, current);

    return _Subscription(node, this, subscription.close);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProviderListenableSelector<T, R> &&
          runtimeType == other.runtimeType &&
          listenable == other.listenable &&
          selector == other.selector;

  @override
  int get hashCode => Object.hash(runtimeType, listenable, selector);
}

abstract class _ProviderListenableBase<T> implements ProviderListenable<T> {
  const _ProviderListenableBase();

  @override
  ProviderListenable<R> select<R>(R Function(T value) selector) =>
      _ProviderListenableSelector(this, selector);
}

class _Subscription<T> extends ProviderSubscription<T> {
  final ProviderListenable<T> provider;
  final void Function() listenerRemover;

  _Subscription(super.source, this.provider, this.listenerRemover);

  @override
  T read() => provider.read(source);

  @override
  void close() {
    super.close();
    listenerRemover();
  }
}
