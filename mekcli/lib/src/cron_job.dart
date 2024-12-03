import 'dart:async';

import 'package:mekart/mekart.dart';
import 'package:mekcli/mekcli.dart';

class CronJob {
  late final _lastExecutionAtBin = BinStore<DateTime?>(
    session: binSession,
    name: 'last_execution_at.json',
    deserializer: (data) => DateTime.parse(data as String),
    serializer: (data) => data?.toIso8601String(),
    fallbackData: null,
  );

  final BinSession binSession;
  final int hour;

  CronJob({required this.binSession, required this.hour});

  Future<void> run(FutureOr<void> Function() runner) async {
    final startedAt = DateTime.now();
    final lastExecutionAt = await _lastExecutionAtBin.read();

    await _ensureCanExecute(startedAt, lastExecutionAt);

    try {
      await _lastExecutionAtBin.write(startedAt);
      await runner();
    } catch (_) {
      await _lastExecutionAtBin.write(null);
      rethrow;
    }
  }

  Future<void> _ensureCanExecute(DateTime startedAt, DateTime? lastExecutionAt) async {
    if (lastExecutionAt == null) throw CliException.executionSkipped();

    final executionStartAt = startedAt.subtract(Duration(hours: hour)).copyDateWith(hour: hour);

    if (lastExecutionAt.isAfter(executionStartAt)) throw CliException.executionSkipped();
  }
}
