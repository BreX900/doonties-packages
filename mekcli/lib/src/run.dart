import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:io/ansi.dart';

class ProcessException extends Error {
  final int exitCode;
  final String? message;

  ProcessException(this.exitCode, [this.message]);

  @override
  String toString() => 'ProcessException: $exitCode';
}

class RunningProcess {
  final Process process;

  RunningProcess._(this.process);

  static Future<RunningProcess> run(String executable, List<String> arguments) async {
    final process = await Process.start(executable, arguments);

    return RunningProcess._(process);
  }

  Stream<Uint8List> get asBytes async* {
    yield* process.stdout.map(Uint8List.fromList);
    await _checkExitCode();
  }

  Future<String> get asString async {
    await _checkExitCode();
    return process.stdout.transform(const Utf8Decoder()).join('\n');
  }

  Future<void> _checkExitCode() async {
    final exitCode = await process.exitCode;
    if (exitCode == 0) return;

    await stderr.addStream(process.stderr);
    throw ProcessException(exitCode);
  }
}

Future<String> runProcess(String executable, List<String> arguments) async {
  final process = await Process.start(executable, arguments);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    await Future.wait([stdout.addStream(process.stdout), stderr.addStream(process.stderr)]);
    throw ProcessException(exitCode);
  }

  return process.stdout.transform(const Utf8Decoder()).join('\n');
}

Future<void> runPrintableProcess(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
}) async {
  // ignore: avoid_print
  print(blue.wrap('\$ ${[executable, ...arguments].join(' ')}'));

  final process = await Process.start(executable, arguments, workingDirectory: workingDirectory);

  await Future.wait([stderr.addStream(process.stderr), stdout.addStream(process.stdout)]);
  final exitCode = await process.exitCode;
  if (exitCode != 0) throw ProcessException(exitCode);
}

Future<void> runScript(
  String prefix,
  String script, {
  required String workingDirectory,
  Map<String, String> environment = const {},
}) async {
  // ignore: avoid_print
  print(yellow.wrap('\$$prefix $script'));

  final workingDir = Directory(workingDirectory);
  if (!workingDir.existsSync()) {
    throw ProcessException(-1, 'Working directory "$workingDirectory" not exist');
  }

  final process = await Process.start(
    Platform.isWindows ? 'cmd.exe' : '/bin/sh',
    Platform.isWindows ? ['/C', '%${'SCRIPT'}%'] : ['-c', 'eval "\$${'SCRIPT'}"'],
    workingDirectory: workingDir.path,
    environment: {...environment, 'SCRIPT': script},
  );

  await Future.wait([stderr.addStream(process.stderr), stdout.addStream(process.stdout)]);

  final exitCode = await process.exitCode;
  if (exitCode != 0) throw ProcessException(exitCode);
}
