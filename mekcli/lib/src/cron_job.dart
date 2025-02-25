import 'dart:async';
import 'dart:io';

import 'package:mekart/mekart.dart';
import 'package:mekcli/mekcli.dart';

void runCliAppWithCronJob(CronJob job, CliApp Function(ProviderRef ref) creator) {
  runWithRef((ref) async {
    final app = creator(ref);
    await job.run(app.run);
  });
}

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

class CronJobMiddleware {
  final CronJob job;

  const CronJobMiddleware(this.job);

  AppHandler call(AppHandler handler) {
    return (ref) async {
      await job.run(() async {
        await handler(ref);
      });
    };
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
    while (true) {
      final now = DateTime.now();
      var startAt = now.withoutTime().copyWith(hour: hour);
      if (startAt.isBefore(now)) startAt = startAt.copyAdding(days: 1);

      final wait = startAt.difference(now);
      print('Scheduled at $startAt and start in $wait');
      await Future<void>.delayed(wait);

      try {
        final startedAt = DateTime.now();
        print('Started at $startedAt');

        await runner();

        final completedAt = DateTime.now();
        print('Finished at $completedAt in ${completedAt.difference(startedAt)}');
      } on CliException catch (exception) {
        stdout.write(exception);
      } catch (error, stackTrace) {
        stderr.write(error);
        stderr.write(stackTrace);
      }
    }
  }
}
