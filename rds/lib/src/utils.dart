import 'dart:io';

import 'package:io/ansi.dart';

Future<void> runCommand(
  String command, {
  String prefix = '',
  String? workingDirectory,
  bool onlyOutputOnError = false,
  Map<String, String> environment = const {},
}) async {
  final message = '$prefix --> $command';
  // ignore: avoid_print
  print(yellow.wrap(message));

  final executable = Platform.isWindows ? 'cmd.exe' : '/bin/sh';
  final process = await Process.start(
    executable,
    Platform.isWindows ? ['/C', '%RDS_SCRIPT%'] : ['-c', r'eval "$RDS_SCRIPT"'],
    workingDirectory: workingDirectory ?? Directory.current.path,
    environment: {'RDS_SCRIPT': command, ...environment},
  );

  if (!onlyOutputOnError) {
    await Future.wait([stderr.addStream(process.stderr), stdout.addStream(process.stdout)]);
  }
  final exitCode = await process.exitCode;

  if (exitCode > 0) {
    // ignore: avoid_print
    print(red.wrap(message));
    if (onlyOutputOnError) {
      await Future.wait([stderr.addStream(process.stderr), stdout.addStream(process.stdout)]);
    }
    exit(exitCode);
  }

  // ignore: avoid_print
  print(green.wrap(message));
}
