import 'package:args/command_runner.dart';
import 'package:rds/bootstrap_command.dart';
import 'package:rds/exec_command.dart';
import 'package:rds/global_command.dart';
import 'package:rds/run_command.dart';

void main(List<String> args) async {
  final runner = CommandRunner('rds', '')
    ..addCommand(RunCommand())
    ..addCommand(GlobalCommand())
    ..addCommand(ExecCommand())
    ..addCommand(BootstrapCommand());

  await runner.run(args);
}
