import 'dart:convert';
import 'dart:io';

import 'package:io/ansi.dart';

class ProcessException extends Error {
  final int exitCode;
  final String? message;

  ProcessException(this.exitCode, [this.message]);

  @override
  String toString() => 'ProcessException: $exitCode';
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

Future<void> runPrintableProcess(String executable, List<String> arguments) async {
  // ignore: avoid_print
  print(blue.wrap('\$ ${[executable, ...arguments].join(' ')}'));

  final process = await Process.start(executable, arguments);

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
