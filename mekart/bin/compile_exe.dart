// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:args/args.dart';
import 'package:mekart/src/cli_utils.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

void main(List<String> args) async {
  final argParser = ArgParser()
    ..addFlag('build-runner', negatable: false)
    ..addOption('define-from-file')
    ..addOption('output');
  final argResults = argParser.parse(args);

  final hasNeedBuildRunner = argResults.flag('build-runner');
  final defineFromFile = argResults.option('define-from-file');
  final outputDirectory = Directory(argResults.option('output') ?? 'build');
  final entrypointPaths = argResults.rest;

  print('Started!');
  if (!outputDirectory.existsSync()) outputDirectory.createSync(recursive: true);

  // Take five minute to complete... soo long...
  if (hasNeedBuildRunner) {
    await runProcess(onCommand: print, 'dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);
  }

  Iterable<String>? defines;
  if (defineFromFile != null) {
    final rawConfig = jsonDecode(File(defineFromFile).readAsStringSync());
    defines =
        (rawConfig as Map<String, dynamic>).entries.map((e) => '--define=${e.key}=${e.value}');
  }

  await Future.wait(entrypointPaths.map((entrypointPath) async {
    const executable = 'dart';
    final arguments = [
      'compile',
      'exe',
      '--define=RELEASE_MODE=true',
      '--output=${outputDirectory.path}/${basenameWithoutExtension(entrypointPath)}.exe',
      entrypointPath,
    ];
    print('$executable ${arguments.join(' ')}');
    await runProcess(executable, [...arguments, ...?defines]);
  }));

  print('Completed!');
}
