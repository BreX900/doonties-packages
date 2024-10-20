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

class _LogReporter {
  final ErrorDetailsMapper onErrorDetails;
  static const _reportDebounceTime = Duration(seconds: 3);
  static var _lastReportAt = DateTime.now().subtract(_reportDebounceTime);
  static bool _canReportAgain = false;

  _LogReporter(this.onErrorDetails);

  void reportToConsole(LogRecord record) {
    if (record.time.isAfter(_lastReportAt)) {
      _canReportAgain = true;
    } else if (_canReportAgain) {
      _canReportAgain = false;
    } else {
      return;
    }
    _lastReportAt = DateTime.now().add(_reportDebounceTime);

    final error = record.error;

    if (error == null) {
      pck_dev.log(
        record.message,
        name: '${record.level.name}:${record.loggerName}',
        error: record.error,
        stackTrace: record.stackTrace,
      );
    } else if (error is FlutterErrorDetails) {
      final entry = _mapErrorAndStackTrace(error.exception, error.stack ?? StackTrace.current);
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
}
