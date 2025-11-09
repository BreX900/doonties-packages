import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart';
import 'package:mek/src/reactive_forms/controls/form_control_typed.dart';
import 'package:mek/src/reactive_forms/reactive_forms.dart';
import 'package:meta/meta.dart';
import 'package:reactive_forms/reactive_forms.dart';

part '_source_consumer_widgets.dart';
part '_source_widgets.dart';
part 'adapters/_listenable_source.dart';
part 'adapters/_reactive_form_sources.dart';
part 'adapters/_reactive_form_sources_extra.dart';
part 'adapters/_source_selector.dart';
part 'adapters/_state_notifier_source.dart';

typedef SourceListener<T> = void Function(T previous, T state);

typedef SourceImmediatelyListener<T> = void Function(T? previous, T state);

mixin class SourceObserver {
  const SourceObserver();

  void onListenerError(SourceNotifier<Object?> notifier, Object error, StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }

  void onUncaughtError(SourceNotifier<Object?> notifier, Object error, StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }
}

@immutable
abstract class Source<T> {
  static SourceObserver observer = const SourceObserver();

  SourceSubscription<T> listen(SourceListener<T> onChange);

  // SourceSubscription<T> listenImmediately(SourceImmediatelyListener<T> onChange);

  SourceSubscription<T> listenImmediately(SourceImmediatelyListener<T> listener) {
    final subscription = listen(listener);
    Zone.current.runBinaryGuarded(listener, null, subscription.read());
    return subscription;
  }
}

class SourceNotifier<T> {
  final _listeners = LinkedList<_ListenersEntry<T>>();
  var _mounted = true;
  T _state;

  SourceNotifier(this._state);

  @protected
  bool get mounted => _mounted;

  Source<T> get source => _Source(this);

  @protected
  T get state {
    assert(_debugIsMounted());
    return _state;
  }

  @protected
  set state(T state) {
    assert(_debugIsMounted());

    final previousState = _state;
    _state = state;

    if (previousState == state) return;
    if (_listeners.isEmpty) return;

    _ListenersEntry<T>? currentEntry = _listeners.first;
    while (currentEntry != null) {
      final previousEntry = currentEntry;
      currentEntry = previousEntry.next;
      try {
        previousEntry.listener(previousState, state);
      } catch (error, stackTrace) {
        Source.observer.onListenerError(this, error, stackTrace);
      }
    }
  }

  @mustCallSuper
  void dispose() {
    assert(_debugIsMounted());
    _listeners.clear();
    _mounted = false;
  }

  bool _debugIsMounted() {
    assert(
      _mounted,
      'Tried to use $runtimeType after `dispose` was called.\nConsider checking `mounted`.',
    );
    return true;
  }
}

class SourceController<T> extends SourceNotifier<T> {
  SourceController(super._state);

  @override
  T get state => super.state;

  @override
  set state(T state) => super.state = state;
}

abstract base class SourceSubscription<T> {
  var _isCancelled = false;

  T read();

  @mustBeOverridden
  @mustCallSuper
  void cancel() {
    assert(debugIsCancelled(this));
    _isCancelled = true;
  }

  static bool debugIsCancelled(SourceSubscription subscription) {
    assert(
      !subscription._isCancelled,
      'Tried to use ${subscription.runtimeType} after `cancel` was called.',
    );
    return true;
  }
}

class _Source<T> extends Source<T> {
  final SourceNotifier<T> _notifier;

  _Source(this._notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    assert(_notifier._debugIsMounted());
    final listenersEntry = _ListenersEntry(listener);
    _notifier._listeners.addFirst(listenersEntry);
    return _SourceSubscription(_notifier, listenersEntry);
  }

  @override
  bool operator ==(Object other) => other is _Source<T> && identical(_notifier, other._notifier);

  @override
  int get hashCode => _notifier.hashCode;
}

final class _ListenersEntry<T> extends LinkedListEntry<_ListenersEntry<T>> {
  final SourceListener<T> listener;

  _ListenersEntry(this.listener);
}

final class _SourceSubscription<T> extends SourceSubscription<T> {
  final SourceNotifier<T> _source;
  final _ListenersEntry<T> _listenersEntry;

  _SourceSubscription(this._source, this._listenersEntry);

  @override
  T read() {
    SourceSubscription.debugIsCancelled(this);
    return _source._state;
  }

  @override
  void cancel() {
    _listenersEntry.unlink();
    super.cancel();
  }
}

class _Optional<T> {
  final T value;

  _Optional(this.value);
}
