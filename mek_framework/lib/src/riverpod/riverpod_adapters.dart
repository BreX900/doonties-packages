import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/utils/_listenable_extensions.dart';
import 'package:mek/src/utils/_state_stremable_extensions.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';
import 'package:rxdart/rxdart.dart';

extension ProviderListenableExtensions2<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<Future<T>> get futureOfData => _IgnoreErrorsProviderListenable(this);
}

extension AsProviderValueStreamExtension<T> on ValueStream<T> {
  ProviderListenable<T> get provider => _ValueStreamProviderListenable<T>(this);
}

extension AsProviderStateStremableExtension<T> on StateStreamable<T> {
  ProviderListenable<T> get provider => _StateStreamableListenable(this);
}

extension AsProviderStateNotififierExtension<T> on StateNotifier<T> {
  ProviderListenable<T> get provider => _StateNotifierListenable(this);
}

extension AsProviderListenableExtension<T> on ValueListenable<T> {
  ProviderListenable<T> get provider => _ValueListenableProviderListenable<T>(this);
}

extension PickListenableExtension<T extends Listenable> on T {
  ProviderListenable<R> pick<R>(R Function(T listenable) picker) => $pick<R>(picker).provider;
}

extension SelectListenableExtension<T> on ValueListenable<T> {
  ProviderListenable<R> select<R>(R Function(T value) selector) => $select(selector).provider;
}

extension SelectStateStreamableExtension<State> on StateStreamable<State> {
  ProviderListenable<R> select<R>(R Function(State state) selector) => $select(selector).provider;
}

extension SelectStateNotifierExtension<State> on StateNotifier<State> {
  ProviderListenable<R> select<R>(R Function(State state) selector) => provider.select(selector);
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

class _ValueStreamProviderListenable<T> extends _ProviderListenable<ValueStream<T>, T> {
  _ValueStreamProviderListenable(super.source);

  @override
  T _read() => source.value;

  @override
  void Function() _addListener(
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required bool fireImmediately,
  }) {
    var current = source.value;
    final subscription = source.listen((next) {
      final prev = current;
      final next = current = source.value;

      listener(prev, next);
    }, onError: onError);

    if (fireImmediately) listener(null, current);

    return subscription.cancel;
  }
}

class _ValueListenableProviderListenable<T> extends _ProviderListenable<ValueListenable<T>, T> {
  _ValueListenableProviderListenable(super.source);

  @override
  T _read() => source.value;

  @override
  void Function() _addListener(
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required bool fireImmediately,
  }) {
    var current = source.value;
    void onChange() {
      final prev = current;
      final next = current = source.value;

      listener(prev, next);
    }

    source.addListener(onChange);

    if (fireImmediately) listener(null, current);

    return () => source.removeListener(onChange);
  }
}

class _StateStreamableListenable<T> extends _ProviderListenable<StateStreamable<T>, T> {
  _StateStreamableListenable(super.source);

  @override
  T _read() => source.state;

  @override
  void Function() _addListener(
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required bool fireImmediately,
  }) {
    var current = source.state;
    final subscription = source.stream.listen((next) {
      final prev = current;
      current = next;

      listener(prev, current);
    });

    if (fireImmediately) listener(null, current);

    return subscription.cancel;
  }
}

class _StateNotifierListenable<T> extends _ProviderListenable<StateNotifier<T>, T> {
  _StateNotifierListenable(super.source);

  @override
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  T _read() => source.state;

  @override
  void Function() _addListener(
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required bool fireImmediately,
  }) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    var current = source.state;
    final listenerRemover = source.addListener((next) {
      final prev = current;
      current = next;

      listener(prev, current);
    });

    if (fireImmediately) listener(null, current);

    return listenerRemover;
  }
}

abstract class _ProviderListenable<S, T> with ProviderListenable<T> {
  final S source;

  _ProviderListenable(this.source);

  T _read();

  void Function() _addListener(
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required bool fireImmediately,
  });

  @override
  T read(Node node) => _read();

  @override
  ProviderSubscription<T> addListener(
    Node node,
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    final closer = _addListener(listener, onError: onError, fireImmediately: fireImmediately);

    return _Subscription(node, _read, closer);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProviderListenable<S, T> &&
          runtimeType == other.runtimeType &&
          source == other.source;

  @override
  int get hashCode => Object.hash(runtimeType, source);
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
