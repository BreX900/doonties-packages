import 'dart:async';
import 'dart:collection';

typedef Task = Future<void> Function();

class TaskQueue {
  final int length;
  final Queue<Task> _pending = Queue();
  final List<Task> _processing = [];
  Completer<void>? _completer;
  List<AsyncError> _errors = [];

  TaskQueue({this.length = 2});

  static Future<void>? wait<T>(
    Iterable<T> elements,
    Future<void> Function(T element) tasker, {
    int parallels = 2,
  }) {
    final queue = TaskQueue(length: parallels);
    queue.addAll(elements, tasker);
    return queue.future;
  }

  int get pendingCount => _pending.length;
  int get processingCount => _processing.length;

  Future<void>? get future => _completer?.future;

  void add(Future<void> Function() task) {
    _completer ??= Completer();
    _pending.addLast(task);

    _next();
  }

  void addAll<T>(Iterable<T> elements, Future<void> Function(T element) tasker) {
    for (final element in elements) {
      add(() async => tasker(element));
    }
  }

  // void addFuture(Future<void> future) => addTask(() => future);
  //
  // void addFutures(Iterable<Future<void>> futures) {
  //   final iterator = futures.iterator;
  //   for (var i = _processing.length; i < length; i++) {
  //     if (!iterator.moveNext()) return;
  //     addFuture(iterator.current);
  //   }
  //   while (iterator.moveNext()) {
  //     addFuture(iterator.current);
  //   }
  // }

  void _next() {
    if (_pending.isEmpty && _processing.isEmpty) {
      if (_errors.isNotEmpty) {
        _completer?.completeError(ParallelWaitError(null, _errors, defaultError: _errors.first));
      } else {
        _completer?.complete();
      }

      _completer = null;
      _errors = [];
      return;
    }

    if (_pending.isEmpty) return;

    if (_processing.length >= length) return;

    final task = _pending.removeFirst();
    _processing.add(task);
    unawaited(_wait(task));
  }

  Future<void> _wait(Task task) async {
    try {
      await task();
    } catch (error, stackTrace) {
      _errors.add(AsyncError(error, stackTrace));
    } finally {
      _processing.remove(task);
      _next();
    }
  }
}
