import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';
import 'package:rxdart/rxdart.dart';

/// Version 2.0.0

extension ProviderListenableExtensions2<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<Future<T>> get futureOfData => _IgnoreErrorsProviderListenable(this);
}

extension AsProviderStreamExtension<T> on Stream<T> {
  ProviderListenable<T> provider(T initialValue) =>
      _StreamProviderListenable<T>(this, initialValue);
}

extension AsProviderValueStreamExtension<T> on ValueStream<T> {
  ProviderListenable<T> get provider => _StreamProviderListenable<T>(this, value);
}

extension AsProviderBlocExtension<T> on StateStreamable<T> {
  ProviderListenable<T> get provider => stream.provider(state);
}

extension AsProviderListenableExtension<T> on ValueListenable<T> {
  ProviderListenable<T> get provider => _ValueProviderListenable<T>(this);
}

extension PickListenableExtension<T extends Listenable> on T {
  ProviderListenable<R> pick<R>(R Function(T listenable) picker) =>
      _ListenablePicker(this, picker).provider;
}

extension SelectListenableExtension<T> on ValueListenable<T> {
  ProviderListenable<R> select<R>(R Function(T value) selector) => provider.select(selector);
}

extension SelectBlocExtension<State> on StateStreamable<State> {
  ProviderListenable<R> select<R>(R Function(State state) selector) => provider.select(selector);
}

class _IgnoreErrorsProviderListenable<T> with ProviderListenable<Future<T>>, EquatableMixin {
  final ProviderListenable<AsyncValue<T>> _provider;

  _IgnoreErrorsProviderListenable(this._provider);

  @override
  ProviderSubscription<Future<T>> addListener(
    // ignore: invalid_use_of_internal_member
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
  // ignore: invalid_use_of_internal_member
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
  List<Object?> get props => [_provider];
}

class _ListenablePicker<T extends Listenable, R> extends ValueListenable<R> with EquatableMixin {
  final T listenable;
  final R Function(T listenable) selector;

  _ListenablePicker(this.listenable, this.selector);

  @override
  void addListener(VoidCallback listener) => listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => listenable.removeListener(listener);

  @override
  R get value => selector(listenable);

  @override
  List<Object?> get props => [listenable, selector];
}

// ignore: must_be_immutable
class _StreamProviderListenable<T> with ProviderListenable<T>, EquatableMixin {
  final Stream<T> stream;
  T _current;

  _StreamProviderListenable(this.stream, this._current);

  @override
  ProviderSubscription<T> addListener(
    // ignore: invalid_use_of_internal_member
    Node node,
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    final subscription = stream.listen((next) {
      final prev = _current;
      _current = next;

      listener(prev, next);
    }, onError: onError);

    if (fireImmediately) listener(null, _current);

    return _Subscription(node, () => _current, subscription.cancel);
  }

  @override
  // ignore: invalid_use_of_internal_member
  T read(Node node) => _current;

  @override
  late final List<Object?> props = [stream];
}

class _ValueProviderListenable<T> with ProviderListenable<T>, EquatableMixin {
  final ValueListenable<T> listenable;

  _ValueProviderListenable(this.listenable);

  @override
  ProviderSubscription<T> addListener(
    // ignore: invalid_use_of_internal_member
    Node node,
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    var current = listenable.value;

    void onChange() {
      final prev = current;
      final next = current = listenable.value;

      listener(prev, next);
    }

    listenable.addListener(onChange);

    if (fireImmediately) listener(null, current);

    return _Subscription(node, () => listenable.value, () => listenable.removeListener(onChange));
  }

  @override
  // ignore: invalid_use_of_internal_member
  T read(Node node) => listenable.value;

  @override
  late final List<Object?> props = [listenable];
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
