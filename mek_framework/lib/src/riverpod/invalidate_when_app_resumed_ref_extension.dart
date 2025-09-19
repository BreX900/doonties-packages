import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension InvalidateWhenAppResumeRefExtenson on Ref {
  void invalidateWhenAppResume() {
    onDispose(_WidgetsBindingRegistry.instance.onAppResumed(invalidateSelf));
  }
}

class _WidgetsBindingRegistry with WidgetsBindingObserver {
  static final _WidgetsBindingRegistry instance = _WidgetsBindingRegistry._();

  final _listeners = LinkedList<_ListenersEntry>();

  _WidgetsBindingRegistry._() {
    WidgetsBinding.instance.addObserver(this);
  }

  VoidCallback onAppResumed(VoidCallback onResumed) {
    final entry = _ListenersEntry(onResumed);
    _listeners.addFirst(entry);
    return entry.unlink;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;

    if (_listeners.isEmpty) return;
    _ListenersEntry? current = _listeners.first;
    while (current != null) {
      final previous = current;
      current = previous.next;
      previous.onResumed();
    }
  }
}

final class _ListenersEntry extends LinkedListEntry<_ListenersEntry> {
  final VoidCallback onResumed;

  _ListenersEntry(this.onResumed);
}
