import 'dart:async';
import 'dart:collection';

typedef Task = Future<void> Function();

class TaskQueue {
  final int length;
  final Queue<Task> _pending = Queue();
  final List<Task> _processing = [];
  Completer<void>? _completer;

  TaskQueue({required this.length});

  int get pendingCount => _pending.length;
  int get processingCount => _processing.length;

  Future<void> get wait => _completer?.future ?? Future<void>.value();

  void add(Future<void> Function() task) {
    _completer ??= Completer();
    _pending.addLast(task);

    _next();
  }

  void _next() {
    if (_pending.isEmpty) {
      _completer?.complete();
      _completer = null;
      return;
    }

    if (_processing.length >= 5) {
      return;
    }

    final task = _pending.removeFirst();
    _processing.add(task);
    unawaited(_wait(task));
  }

  Future<void> _wait(Task task) async {
    try {
      await task();
    } finally {
      _processing.remove(task);
      _next();
    }
  }
}
