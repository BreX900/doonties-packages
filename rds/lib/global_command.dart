import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:rds/src/rds.dart';
import 'package:rds/src/utils.dart';

class GlobalCommand extends Command<void> {
  @override
  String get name => 'global';

  @override
  String get description => name;

  @override
  ArgParser get argParser => ArgParser.allowAnything();

  @override
  Future<void> run() async {
    final scriptName = argResults!.rest.single;

    final rds = await Rds.find(Directory.current);

    final script = rds.scripts[scriptName];
    if (script == null) throw StateError('Script $scriptName not exist!');

    await runCommand(script, environment: {'RDS_TYPE': 'SINGLE'});
  }
}
