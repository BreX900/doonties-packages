import 'package:mekart/mekart.dart';
import 'package:mekcli/mekcli.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeBinSession extends Fake implements BinSession {}

void main() {
  final cronJob = CronJob(binSession: _FakeBinSession(), hour: 14);

  test('can execute if never executed', () {
    final startedAt = DateTime.utc(2000, 10, 05);
    const lastExecutionAt = null;

    expect(cronJob.checkCanExecute(startedAt, lastExecutionAt), true);
  });

  test('can execute', () {
    final startedAt = DateTime.utc(2000, 10, 05, 14);
    final lastExecutionAt = DateTime.utc(2000, 10, 04, 14);

    expect(cronJob.checkCanExecute(startedAt, lastExecutionAt), true);
  });

  test('can execute 2', () {
    final startedAt = DateTime.utc(2000, 10, 05, 14);
    final lastExecutionAt = DateTime.utc(2000, 10, 05, 02);

    expect(cronJob.checkCanExecute(startedAt, lastExecutionAt), true);
  });

  test('cant execute', () {
    final startedAt = DateTime.utc(2000, 10, 05, 14);
    final lastExecutionAt = DateTime.utc(2000, 10, 05, 14);

    expect(cronJob.checkCanExecute(startedAt, lastExecutionAt), false);
  });

  test('cant execute 2', () {
    final startedAt = DateTime.utc(2000, 10, 05, 03);
    final lastExecutionAt = DateTime.utc(2000, 10, 05, 02);

    expect(cronJob.checkCanExecute(startedAt, lastExecutionAt), false);
  });
}