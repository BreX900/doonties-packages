import 'dart:async';

import 'package:mekart/mekart.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';

abstract class StateListenable<T> {
  T get state;

  void Function() addListener(void Function(T state) listener);
}

abstract class SourceProviderListenable<S, T> extends _StateProviderListenable<T> {
  final S source;

  const SourceProviderListenable(this.source);

  @override
  bool updateShouldNotify(T prev, T next) => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceProviderListenable &&
          runtimeType == other.runtimeType &&
          source == other.source;

  @override
  int get hashCode => Object.hash(runtimeType, source);
}

abstract class _StateProviderListenable<T> implements ProviderListenable<T> {
  const _StateProviderListenable();

  T get state;

  bool updateShouldNotify(T prev, T next);

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
  ProviderListenable<R> select<R>(R Function(T value) selector) =>
      _ProviderListenableSelector(this, selector);
}

class _ProviderListenableSelector<T, R> implements ProviderListenable<R> {
  final ProviderListenable<T> _listenable;
  final R Function(T state) _selector;

  const _ProviderListenableSelector(this._listenable, this._selector);

  bool updateShouldNotify(R prev, R next) => !iEquality.equals(prev, next);

  @override
  R read(Node node) => _selector(_listenable.read(node));

  @override
  ProviderSubscription<R> addListener(
    Node node,
    void Function(R? previous, R next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    late R current;
    final subscription = _listenable.addListener(
      node,
      (_, next) {
        final prev = current;
        current = _selector(next);

        if (updateShouldNotify(prev, current)) listener(prev, current);
      },
      onError: onError,
      onDependencyMayHaveChanged: onDependencyMayHaveChanged,
      fireImmediately: false,
    );
    current = _selector(subscription.read());
    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, current);

    return _Subscription(node, this, subscription.close);
  }

  @override
  ProviderListenable<S> select<S>(S Function(R value) selector) =>
      _ProviderListenableSelector(this, selector);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProviderListenableSelector<T, R> &&
          runtimeType == other.runtimeType &&
          _listenable == other._listenable &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(runtimeType, _listenable, _selector);
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
