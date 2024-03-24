import 'dart:async';
import 'dart:developer' as pck_dev;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mek/src/logs/crashlytics.dart';

class ErrorDetails {
  final Object error;
  final StackTrace stackTrace;

  ErrorDetails(this.error, this.stackTrace);
}

typedef ErrorDetailsMapper = ErrorDetails Function(Object error, StackTrace stackTrace);

extension ReportRecordsExtension on Logger {
  void reportRecords({
    Crashlytics crashlytics = Crashlytics.none,
    ErrorDetailsMapper? onErrorDetails,
  }) {
    Logger.root.level = kReleaseMode ? Level.CONFIG : Level.ALL;

    final reporter = _LogReporter(onErrorDetails ?? ErrorDetails.new);

    Logger.root.onRecord.listen(reporter.reportToConsole, onError: reporter._printLoggingError);
    if (kReleaseMode && crashlytics != Crashlytics.none) {
      Logger.root.onRecord
          .asyncMap((error) async => await reporter.reportToCrashlytics(crashlytics, error))
          .listen(null, onError: reporter._printLoggingError);
    }
  }
}

typedef _PWE<T> = ParallelWaitError<dynamic, T>;
typedef _AE = AsyncError?;

class _LogReporter {
  final ErrorDetailsMapper onErrorDetails;

  _LogReporter(this.onErrorDetails);

  void reportToConsole(LogRecord record) {
    final error = record.error;

    if (error == null) {
      pck_dev.log(
        record.message,
        name: '${record.level.name}:${record.loggerName}',
        error: record.error,
        stackTrace: record.stackTrace,
      );
    } else if (error is FlutterErrorDetails) {
      final entry = _mapErrorAndStackTrace(error.exception, error.stack!);
      final details = error.copyWith(
        exception: entry.error,
        stack: entry.stackTrace,
      );
      FlutterError.dumpErrorToConsole(forceReport: true, details);
    } else {
      final entry = _mapErrorAndStackTrace(record.error!, record.stackTrace!);
      FlutterError.dumpErrorToConsole(
        forceReport: true,
        FlutterErrorDetails(
          library: '${record.level.name}:${record.loggerName}',
          context: ErrorSummary(record.message),
          exception: entry.error,
          stack: entry.stackTrace,
        ),
      );
    }
    if (error != null) _log(error);
  }

  Future<void> reportToCrashlytics(Crashlytics crashlytics, LogRecord record) async {
    final error = record.error;

    if (error == null) {
      await crashlytics.log('[${record.level}] ${record.time}: ${record.message}');
    } else if (error is FlutterErrorDetails) {
      await crashlytics.reportFlutterError(
        message: record.message,
        error: error,
      );
    } else {
      await crashlytics.reportError(
        message: record.message,
        error: error,
        stackTrace: record.stackTrace,
      );
    }
  }

  ErrorDetails _mapErrorAndStackTrace(Object error, StackTrace stackTrace) {
    return onErrorDetails(error, stackTrace);
  }

  void _printLoggingError(Object error, StackTrace stackTrace) {
    debugPrint('Error when log is logged\n$error');
    debugPrintStack(stackTrace: stackTrace);
  }

  void _log(Object error) {
    switch (error) {
      case ParallelWaitError<dynamic, dynamic>():
        final errors = _resolveAsyncErrors(error).nonNulls.toList();
        for (final e in errors) {
          _printLoggingError(e.error, e.stackTrace);
        }
    }
  }

  List<AsyncError?> _resolveAsyncErrors(ParallelWaitError<dynamic, dynamic> error) {
    switch (error) {
      case _PWE<(_AE, _AE)>(errors: final e):
        return [e.$1, e.$2];
      case _PWE<(_AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3];
      case _PWE<(_AE, _AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3, e.$4];
      case _PWE<(_AE, _AE, _AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3, e.$4, e.$5];
      case _PWE<(_AE, _AE, _AE, _AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3, e.$4, e.$5, e.$6];
      case _PWE<(_AE, _AE, _AE, _AE, _AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3, e.$4, e.$5, e.$6, e.$7];
      case _PWE<(_AE, _AE, _AE, _AE, _AE, _AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3, e.$4, e.$5, e.$6, e.$7, e.$8];
      case _PWE<(_AE, _AE, _AE, _AE, _AE, _AE, _AE, _AE, _AE)>(errors: final e):
        return [e.$1, e.$2, e.$3, e.$4, e.$5, e.$6, e.$7, e.$8, e.$9];
    }
    throw UnsupportedError('${error.errors}');
  }
}

class ReportedException {
  final Type type;
  final String message;

  const ReportedException(this.type, this.message);

  @override
  Type get runtimeType => type;

  @override
  String toString() => message;
}

class ReportedStackTrace implements StackTrace {
  final StackTrace previous;
  final StackTrace next;

  const ReportedStackTrace(this.previous, this.next);

  @override
  String toString() => '$previous\n$next';
}
