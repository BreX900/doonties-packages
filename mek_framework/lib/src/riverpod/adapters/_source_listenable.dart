import 'dart:async';
import 'dart:collection';

import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:meta/meta.dart';

@experimental
class SourceListenable<T> implements StateListenable<T> {
  final _listeners = LinkedList<_ListenerEntry<T>>();
  T _state;

  SourceListenable(this._state);

  @override
  void Function() listen(void Function(T state) listener) {
    final listenerEntry = _ListenerEntry(listener);
    _listeners.add(listenerEntry);
    return listenerEntry.maybeUnlink;
  }

  @override
  T get state => _state;

  void emit(T state) {
    _state = state;

    for (final listenerEntry in _listeners) {
      try {
        listenerEntry.listener(state);
      } catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    }
  }

  void dispose() {
    _listeners.clear();
  }
}

final class _ListenerEntry<T> extends LinkedListEntry<_ListenerEntry<T>> {
  _ListenerEntry(this.listener);

  final void Function(T state) listener;

  void maybeUnlink() {
    if (list == null) return;
    unlink();
  }
}
