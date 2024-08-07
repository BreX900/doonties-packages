import 'dart:io';

import 'package:logging/logging.dart';

const bool kReleaseMode = bool.fromEnvironment('RELEASE_MODE');
const bool kDebugMode = !kReleaseMode;

final lg = Logger.detached('app');

Future<void> runProcess(
  String executable,
  List<String> arguments, {
  void Function(String command)? onCommand,
}) async {
  onCommand?.call('$executable ${arguments.join(' ')}');
  final process = await Process.start(executable, arguments);

  await Future.wait([process.stdout.forEach(stdout.add), process.stderr.forEach(stderr.add)]);

  final exitCode = await process.exitCode;
  if (exitCode != 0) exit(exitCode);
}
