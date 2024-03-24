import 'dart:async';

abstract class Result<T> {
  static Result<R> of<R>(R Function() task) {
    try {
      final data = task();
      return _DataResult(data);
    } catch (error, stackTrace) {
      return _ErrorResult(error, stackTrace);
    }
  }

  static Future<Result<R>> from<R>(FutureOr<R> Function() task) async {
    try {
      final data = await task();
      return _DataResult(data);
    } catch (error, stackTrace) {
      return _ErrorResult(error, stackTrace);
    }
  }

  R map<R>(R Function(Object error, StackTrace stackTrace) onError, R Function(T data) onData);
}

class _ErrorResult<T> implements Result<T> {
  final Object error;
  final StackTrace stackTrace;

  _ErrorResult(this.error, this.stackTrace);

  @override
  R map<R>(R Function(Object error, StackTrace stackTrace) onError, R Function(T data) onData) =>
      onError(error, stackTrace);
}

class _DataResult<T> implements Result<T> {
  final T data;

  _DataResult(this.data);

  @override
  R map<R>(R Function(Object error, StackTrace stackTrace) onError, R Function(T data) onData) =>
      onData(data);
}
