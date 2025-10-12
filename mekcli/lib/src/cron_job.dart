import 'dart:async';

import 'package:mekart/mekart.dart';
import 'package:mekcli/mekcli.dart';

typedef AppHandler = Future<void> Function(ProviderRef ref);
typedef AppMiddleware = AppHandler Function(AppHandler handler);

class AppPipeline {
  const AppPipeline();

  AppPipeline addMiddleware(AppMiddleware middleware) => _AppPipeline(middleware, addHandler);

  AppHandler addHandler(AppHandler handler) => handler;
}

class _AppPipeline extends AppPipeline {
  final AppMiddleware _middleware;
  final AppMiddleware _parent;

  const _AppPipeline(this._middleware, this._parent);

  @override
  AppHandler addHandler(AppHandler handler) => _parent(_middleware(handler));
}

class CliAppHandler {
  final CliApp Function(ProviderRef ref) creator;

  const CliAppHandler(this.creator);

  Future<void> call(ProviderRef ref) async {
    final handler = creator(ref);
    return await handler.run();
  }
}

abstract class CronJob {
  final int hour;

  const factory CronJob({required int hour}) = _CronJob;

  factory CronJob.fromBin({required BinSession session, required int hour}) = _CronJobFromBin;

  const CronJob._({required this.hour});

  Future<void> run(FutureOr<void> Function() runner);

  // 05-15:01->05-14:00 05-14:01 -> executionStartAt isAfter lastExecutionAt -> false throw
  // 05-15:01->05-14:00 04-14:01 -> executionStartAt isAfter lastExecutionAt -> true execute
  bool checkCanExecute(DateTime startedAt, DateTime? lastExecutionAt) {
    if (lastExecutionAt == null) return true;

    final executionStartAt = startedAt.subtract(Duration(hours: hour)).copyDateWith(hour: hour);

    return executionStartAt.isAfter(lastExecutionAt);
  }
}

class _CronJobFromBin extends CronJob {
  late final _lastExecutionAtBin = BinStore<DateTime?>(
    session: session,
    name: 'last_execution_at.json',
    deserializer: (data) => DateTime.parse(data as String),
    serializer: (data) => data?.toIso8601String(),
    fallbackData: null,
  );

  final BinSession session;

  _CronJobFromBin({required this.session, required super.hour}) : super._();

  @override
  Future<void> run(FutureOr<void> Function() runner) async {
    final startedAt = DateTime.now();
    final lastExecutionAt = await _lastExecutionAtBin.read();

    if (!checkCanExecute(startedAt, lastExecutionAt)) throw CliException.executionSkipped();

    try {
      try {
        await _lastExecutionAtBin.write(startedAt);
        await runner();
      } on CliException catch (exception) {
        if (exception.type != CliExceptionType.executionEmpty) rethrow;
      }
    } catch (_) {
      await _lastExecutionAtBin.write(null);
      rethrow;
    }
  }
}

class _CronJob extends CronJob {
  const _CronJob({required super.hour}) : super._();

  @override
  Future<void> run(FutureOr<void> Function() runner) async {
    await _run(runner);

    while (true) {
      final now = DateTime.timestamp();
      var startAt = now.withoutTime().copyWith(hour: hour);
      if (startAt.isBefore(now)) startAt = startAt.copyAdding(days: 1);

      final wait = startAt.difference(now);
      lg.config(
        'Scheduled at ${startAt.toSimpleString()} and start '
        'in ${wait.toShortString(milliseconds: false)}...\n',
      );
      await Future<void>.delayed(wait);

      await _run(runner);
    }
  }

  Future<void> _run(FutureOr<void> Function() runner) async {
    try {
      await runner();
    } catch (error, stackTrace) {
      lg.severe('Crash on cron jon', error, stackTrace);
    }
  }
}

extension on DateTime {
  String toSimpleString() => toString().split('.').first;
}

abstract class AppMiddlewareBase {
  const AppMiddlewareBase();

  AppHandler call(AppHandler handler) =>
      (ref) => onCall(ref, handler);

  Future<void> onCall(ProviderRef ref, AppHandler handler);
}

class TimerMiddleware extends AppMiddlewareBase {
  const TimerMiddleware();

  @override
  Future<void> onCall(ProviderRef ref, AppHandler handler) async {
    final startedAt = DateTime.timestamp();
    lg.config('Started at ${startedAt.toSimpleString()}');

    try {
      await handler(ref);
    } finally {
      final completedAt = DateTime.timestamp();
      lg.config(
        'Finished at ${completedAt.toSimpleString()} '
        'in ${completedAt.difference(startedAt).toShortString()}',
      );
    }
  }
}

class CliExceptionMiddleware extends AppMiddlewareBase {
  const CliExceptionMiddleware();

  @override
  Future<void> onCall(ProviderRef ref, AppHandler handler) async {
    try {
      await handler(ref);
    } on CliException catch (exception) {
      lg.warning('$exception');
    }
  }
}
