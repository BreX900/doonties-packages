import 'dart:async';

import 'package:mek/src/core/_result.dart';

class TasksProcessor<T> {
  Future<T> Function()? _nextTask;
  Completer<T>? _completer;

  Future<T> process(Future<T> Function() task) {
    if (_completer != null) {
      _nextTask = task;
      return _completer!.future;
    }

    _completer = Completer();
    return _processNow(_completer!, task);
  }

  Future<T> _processNow(Completer<T> completer, Future<T> Function() task) async {
    final result = await Result.from(task);

    if (completer.isCompleted) return completer.future;

    final nextTask = _nextTask;
    if (nextTask != null) {
      _nextTask = null;
      return _processNow(completer, nextTask);
    }

    return result.map((error, stackTrace) {
      completer.completeError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }, (data) {
      completer.complete(data);
      _completer = null;
      return data;
    });
  }
}
