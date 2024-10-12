import 'dart:async';

import 'package:mekart/mekart.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';

abstract class StateListenable<T> {
  T get state;

  void Function() listen(void Function(T state) listener);
}

abstract class SourceProviderListenable<S, T> extends _StateProviderListenable<T> {
  final S source;

  const SourceProviderListenable(this.source);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceProviderListenable &&
          runtimeType == other.runtimeType &&
          source == other.source;

  @override
  int get hashCode => Object.hash(runtimeType, source);
}

class _StateListenableProviderSelector<T, R> extends _StateProviderListenable<R> {
  final StateListenable<T> _listenable;
  final R Function(T state) _selector;

  const _StateListenableProviderSelector(this._listenable, this._selector);

  @override
  void Function() listen(void Function(R state) listener) =>
      _listenable.listen((state) => listener(_selector(state)));

  @override
  R get state => _selector(_listenable.state);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _StateListenableProviderSelector<T, R> &&
          runtimeType == other.runtimeType &&
          _listenable == other._listenable &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(runtimeType, _listenable, _selector);
}

abstract class _StateProviderListenable<T> implements ProviderListenable<T>, StateListenable<T> {
  const _StateProviderListenable();

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

      if (iEquality.equals(prev, next)) return;

      listener(prev, next);
    });

    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, current);

    return _Subscription(node, this, subscription);
  }

  @override
  ProviderListenable<R> select<R>(R Function(T value) selector) =>
      _StateListenableProviderSelector(this, selector);
}

class _Subscription<T> extends ProviderSubscription<T> {
  final _StateProviderListenable<T> provider;
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
