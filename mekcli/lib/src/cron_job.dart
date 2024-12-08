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

    if (!checkCanExecute(startedAt, lastExecutionAt)) throw CliException.executionSkipped();

    try {
      await _lastExecutionAtBin.write(startedAt);
      await runner();
    } catch (_) {
      await _lastExecutionAtBin.write(null);
      rethrow;
    }
  }

  // 05-15:01->05-14:00 05-14:01 -> executionStartAt isAfter lastExecutionAt -> false throw
  // 05-15:01->05-14:00 04-14:01 -> executionStartAt isAfter lastExecutionAt -> true execute
  bool checkCanExecute(DateTime startedAt, DateTime? lastExecutionAt) {
    if (lastExecutionAt == null) return true;

    final executionStartAt = startedAt.subtract(Duration(hours: hour)).copyDateWith(hour: hour);

    return executionStartAt.isAfter(lastExecutionAt);
  }
}
