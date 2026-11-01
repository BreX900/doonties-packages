import 'dart:async';

import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';
import 'package:timezone/data/latest_10y.dart' as tz_db;
import 'package:timezone/timezone.dart' as tz;

final class Cron {
  final _jobs = <CronJob>[];

  List<CronJob> get jobs => List.unmodifiableOf(_jobs);

  Cron();

  void initializeTimeZone() => tz_db.initializeTimeZones();

  void schedule(CronJob job) {
    _jobs.add(job);
  }

  void scheduleAll(Iterable<CronJob> jobs) {
    _jobs.addAll(jobs);
  }

  void start() {
    for (final job in _jobs) {
      unawaited(_startJob(job));
    }
  }

  Future<void> _startJob(CronJob job) async {
    final now = tz.TZDateTime.now(tz.getLocation(job._timezone));

    var nextAt = now.copyWith(
      hour: job._hour,
      minute: job._minute,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
    if (nextAt.isBefore(now)) nextAt = nextAt.copyWith(day: nextAt.day + 1);

    await job.wait(nextAt, nextAt.difference(now));

    await job.executeGuarded();

    unawaited(_startJob(job));
  }
}

enum CronStatus { idle, waiting, executing, error, success }

class const CronState<T>({
  required final CronStatus status,
  required final DateTime? startsAt,
  required final DateTime? startedAt,
  required final Duration? completedIn,
  required final (Object, StackTrace)? errorAndStackTrace,
  required final T? result,
}) {
  factory CronState.idle() => CronState(
    status: .idle,
    startsAt: null,
    startedAt: null,
    completedIn: null,
    errorAndStackTrace: null,
    result: null,
  );

  // CronState _toIdle() => copyWith(status: .idle);

  CronState<T> _toWaiting(DateTime startsAt) => copyWith(status: .waiting, startsAt: startsAt);

  CronState<T> _toExecuting(DateTime startedAt) => copyWith(
    status: .executing,
    startedAt: startedAt,
    completedIn: null,
    errorAndStackTrace: null,
  );

  CronState<T> _toError(Duration completedIn, Object error, StackTrace stackTrace) =>
      copyWith(status: .error, completedIn: completedIn, errorAndStackTrace: (error, stackTrace));

  CronState<T> _toSuccess(Duration completedIn, T result) =>
      copyWith(status: .success, completedIn: completedIn, result: result);

  CronState<T> copyWith({
    FutureOr<DateTime>? startsAt = const Unspecified(),
    FutureOr<DateTime?> startedAt = const Unspecified(),
    FutureOr<Duration?> completedIn = const Unspecified(),
    FutureOr<CronStatus> status = const Unspecified(),
    FutureOr<(Object, StackTrace)?> errorAndStackTrace = const Unspecified(),
    FutureOr<T?> result = const Unspecified(),
  }) {
    return CronState(
      startsAt: Unspecified.resolve(this.startsAt, startsAt),
      startedAt: Unspecified.resolve(this.startedAt, startedAt),
      completedIn: Unspecified.resolve(this.completedIn, completedIn),
      status: Unspecified.resolve(this.status, status),
      errorAndStackTrace: Unspecified.resolve(this.errorAndStackTrace, errorAndStackTrace),
      result: Unspecified.resolve(this.result, result),
    );
  }
}

@optionalTypeArgs
class CronJob<T>(
  final Future<T> Function() _executor, {
  final String _timezone = 'Etc/UTC',
  required final int _hour,
  final int _minute = 0,
}) {
  var _state = CronState<T>.idle();

  CronState get state => _state;

  Future<void> wait(DateTime startsAt, Duration duration) async {
    _state = _state._toWaiting(startsAt);
    await Future<void>.delayed(duration);
  }

  Future<T> execute() async {
    final startedAt = tz.TZDateTime.now(tz.getLocation(_timezone));
    _state = _state._toExecuting(startedAt);
    try {
      final result = await _executor();

      final endedAt = tz.TZDateTime.now(tz.getLocation(_timezone));
      _state = _state._toSuccess(endedAt.difference(startedAt), result);

      return result;
    } catch (error, stackTrace) {
      final endedAt = tz.TZDateTime.now(tz.getLocation(_timezone));
      _state = _state._toError(endedAt.difference(startedAt), error, stackTrace);
      rethrow;
    }
  }

  Future<void> executeGuarded() async {
    try {
      await execute();
    } catch (error, stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
    }
  }
}

extension TZDateTimeExtensions on tz.TZDateTime {
  tz.TZDateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    bool? isUtc,
  }) {
    return tz.TZDateTime(
      location,
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
