import 'package:flutter_test/flutter_test.dart';
import 'package:mek/src/shared/_task_processor.dart';

void main() {
  late TasksProcessor<String> tasks;
  late List<String> calls;

  setUp(() {
    tasks = TasksProcessor();
    calls = <String>[];
  });

  const first = '#firstResult';
  const second = '#SecondResult';

  Future<String> delayed(String value, int delay) {
    calls.add(value);
    return Future.delayed(Duration(milliseconds: 100 * delay), () => value);
  }

  Future<String> firstDelayed() async => await delayed(first, 2);
  Future<String> secondDelayed() async => await delayed(second, 1);

  group('TaskProcessor', () {
    test('execute task', () async {
      await expectLater(tasks.process(firstDelayed), completion(first));
      expect(calls, [first]);
    });

    test('complete all with second task result', () async {
      await Future.wait([
        expectLater(tasks.process(firstDelayed), completion(second)),
        expectLater(tasks.process(secondDelayed), completion(second)),
      ]);
      expect(calls, [first, second]);
    });
  });
}
