import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:rds/src/project.dart';
import 'package:rds/src/utils.dart';

class RunCommand extends Command<void> {
  @override
  String get name => 'run';

  @override
  String get description => name;

  @override
  ArgParser get argParser => ArgParser.allowAnything();

  @override
  Future<void> run() async {
    final scriptName = argResults!.rest.single;

    final project = await Project.read(Directory.current);

    final script = project.scripts[scriptName];
    if (script == null) throw StateError('Script $scriptName not exist!');

    await runCommand(script);
  }
}
