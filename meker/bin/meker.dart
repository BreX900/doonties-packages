import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:args/command_runner.dart';

import '../tool/export_schema.dart';
import '../tool/generate_migrator.dart';

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          'meker',
          'Gestisce gli schemi e le migrazioni Drift. Esegui dalla directory del server.',
        )
        ..addCommand(_ExportSchema())
        ..addCommand(_GenerateMigrator());

  try {
    await runner.run(args);
  } on UsageException catch (error) {
    stderr.writeln(error);
    exitCode = 64;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

class _ExportSchema extends Command<void> {
  @override
  String get name => 'export-schema';

  @override
  String get description => 'Compila i moduli Drift ed esporta lo schema versionato.';

  @override
  bool get takesArguments => false;

  @override
  Future<void> run() => exportSchema();
}

class _GenerateMigrator extends Command<void> {
  @override
  String get name => 'generate-migrator';

  @override
  String get description => 'Genera le classi degli schemi e il codice di migrazione.';

  @override
  bool get takesArguments => false;

  @override
  void run() => generateMigrator();
}
