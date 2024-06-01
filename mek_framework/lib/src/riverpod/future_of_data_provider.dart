import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';

extension ProviderListenableExtensions2<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<Future<T>> get futureOfData => _IgnoreErrorsProviderListenable(this);
}

class _IgnoreErrorsProviderListenable<T> with ProviderListenable<Future<T>> {
  final ProviderListenable<AsyncValue<T>> _provider;

  _IgnoreErrorsProviderListenable(this._provider);

  @override
  ProviderSubscription<Future<T>> addListener(
    Node node,
    void Function(Future<T>? previous, Future<T> next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    Completer<T>? completer;

    final subscription = node.listen(fireImmediately: fireImmediately, onError: onError, _provider,
        (previous, next) {
      next.whenOrNull(
        skipLoadingOnRefresh: false,
        data: (data) {
          completer?.complete(data);
          completer = null;

          listener(
            previous != null && previous.hasValue ? Future.value(previous.requireValue) : null,
            Future.value(data),
          );
        },
      );
    });

    return _Subscription(node, () {
      final state = subscription.read();
      if (!state.hasValue) {
        completer = Completer.sync();
        return completer!.future;
      }
      return Future.value(state.requireValue);
    }, subscription.close);
  }

  @override
  Future<T> read(Node node) {
    final state = _provider.read(node);
    if (!state.hasValue) {
      final completer = Completer<T>.sync();
      late final ProviderSubscription<AsyncValue<T>> subscription;
      subscription = node.listen(_provider, (_, state) {
        state.whenOrNull(
          skipLoadingOnRefresh: false,
          data: (data) {
            subscription.close();
            completer.complete(data);
          },
        );
      });
      return completer.future;
    }
    return Future.value(state.requireValue);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _IgnoreErrorsProviderListenable<T> &&
          runtimeType == other.runtimeType &&
          _provider == other._provider;

  @override
  int get hashCode => Object.hash(runtimeType, _provider);
}

class _Subscription<T> extends ProviderSubscription<T> {
  final T Function() reader;
  final void Function() closer;

  _Subscription(super.source, this.reader, this.closer);

  @override
  T read() => reader();

  @override
  void close() {
    super.close();
    closer();
  }
}
