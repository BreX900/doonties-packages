import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:pool/pool.dart';
import 'package:rds/src/project.dart';
import 'package:rds/src/utils.dart';

class ExecCommand extends Command<void> {
  @override
  String get name => 'exec';

  @override
  String get description => name;

  @override
  ArgParser get argParser => ArgParser.allowAnything();

  @override
  Future<void> run() async {
    final scriptName = argResults!.rest.single;

    final projects = await Project.find(Directory.current).toList();
    final pool = Pool(4);

    await pool.forEach(projects, (project) async {
      if (project.path == Directory.current.path) return;

      final script = project.scripts[scriptName];
      if (script == null) return;

      await runCommand(
        script,
        workingDirectory: project.path,
        onlyOutputOnError: true,
        prefix: '${relative(project.path)}: ',
      );
    }).drain();
  }
}
