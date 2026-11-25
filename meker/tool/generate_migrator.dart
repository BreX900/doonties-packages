import 'dart:convert';
import 'dart:io';

import 'package:meker/src/migrator/schema_snapshot.dart';
import 'package:meker/src/migrator/schema_table.dart';
import 'package:yaml_codec/yaml_codec.dart';

final _columnTypes = {for (final type in SchemaColumnType.values) type.driftName: type};

void generateMigrator() {
  final inputs = Directory('drift_schemas');
  final output = Directory('lib/api/database');

  final versions = <int, String>{};
  final versionFile = RegExp(r'^([1-9][0-9]*)\.yaml$');
  for (final input in inputs.listSync().whereType<File>()) {
    final match = versionFile.firstMatch(input.uri.pathSegments.last);
    if (match == null) continue;
    try {
      final version = int.parse(match[1]!);
      final data = yamlDecode(input.readAsStringSync());
      versions[version] = _generateClasses(SnapshotDatabase.fromJson(data), version);
    } on FormatException catch (error) {
      throw FormatException('${input.path}: ${error.message}');
    }
  }
  final ordered = versions.keys.toList()..sort();
  if (ordered.isEmpty) {
    throw FormatException('Nessuno schema versionato in ${inputs.path}');
  }
  for (final version in ordered) {
    File('${output.path}/schema_v$version.dart').writeAsStringSync(versions[version]!);
  }
  File('${output.path}/schema_migrations.dart').writeAsStringSync(_generateMigration(ordered));
  stdout.writeln('Schemi generati per le versioni ${ordered.join(', ')}');
}

String _generateClasses(SnapshotDatabase snapshot, int version) {
  if (snapshot.tables.isNotEmpty) {
    final source = StringBuffer()
      ..writeln('// Generato da drift_schemas/$version.yaml. Modifica lo schema sorgente.')
      ..writeln()
      ..writeln("import 'package:server/api/database/schema_table.dart';")
      ..writeln();
    final tableClasses = StringBuffer();
    source
      ..writeln('final class SchemaV$version {')
      ..writeln('  static const version = $version;');
    final classNames = <String>{};
    for (final table in snapshot.tables.entries) {
      final suffix = _pascalCase(table.key);
      final className = '${suffix}Table';
      if (!RegExp('^[A-Z]').hasMatch(suffix) || !classNames.add(className)) {
        throw FormatException('Tabella non valida o in conflitto: ${table.key}');
      }
      final metadata = table.value;

      final fieldName = suffix[0].toLowerCase() + suffix.substring(1);
      source.writeln('  final $fieldName = $className();');
      tableClasses
        ..writeln('final class $className extends SchemaTable {')
        ..writeln('  @override')
        ..writeln('  String get name => ${_dartString(table.key)};');
      final fieldNames = <String>{};
      final columns = metadata.columns;
      final primaryKey = <String>[];
      for (final name in metadata.primaryKey) {
        if (!columns.containsKey(name)) {
          throw FormatException('Colonna $name della chiave primaria non valida per ${table.key}');
        }
        primaryKey.add(_columnFieldName(name));
      }
      for (final column in columns.entries) {
        final fieldName = _columnFieldName(column.key);
        if (fieldName.isEmpty || !fieldNames.add(fieldName)) {
          throw FormatException('Colonna non valida o in conflitto: ${table.key}.${column.key}');
        }
        final name = _dartString(column.key);
        final field = column.value;
        final type = _columnTypes[field.type];
        if (type == null) {
          throw FormatException(
            'Tipo Drift non supportato per ${table.key}.${column.key}: ${field.type}',
          );
        }
        final declaration = '  late final $fieldName =';
        final defaultValue = field.defaultValue;
        final customConstraints = field.customConstraints;
        final arguments = [
          'tableName: name',
          'name: $name',
          'type: SchemaColumnType.${type.name}',
          if (field.nullable) 'nullable: true',
          if (field.autoIncrement) 'autoIncrement: true',
          if (defaultValue != null) 'defaultValue: ${_dartString(defaultValue)}',
          if (customConstraints != null) 'customConstraints: ${_dartString(customConstraints)}',
          if (field.constraints.isNotEmpty) _checkArgument(field.constraints),
          if (field.foreignKey case DriftSchemaForeignKey(
            :final referencedTable,
            :final referencedColumn,
          ))
            'foreignKey: const SchemaReference(tableName: ${_dartString(referencedTable)}, name: ${_dartString(referencedColumn)})',
        ];
        final value = "SchemaColumn(${arguments.join(', ')})";
        tableClasses.writeln();
        if (!value.contains('\n') && '$declaration $value;'.length <= 100) {
          tableClasses.writeln('$declaration $value;');
        } else {
          tableClasses
            ..writeln('$declaration SchemaColumn(')
            ..writeln("    ${arguments.join(',\n    ')},")
            ..writeln('  );');
        }
      }
      _writeListGetter(tableClasses, 'SchemaColumn', 'columns', fieldNames);
      _writeListGetter(tableClasses, 'SchemaColumn', 'primaryKey', primaryKey);
      if (metadata.uniqueKeys.isNotEmpty) {
        final uniqueKeys = <String>[];
        for (final key in metadata.uniqueKeys) {
          final fields = <String>[];
          for (final name in key) {
            if (!columns.containsKey(name)) {
              throw FormatException('Colonna $name del vincolo UNIQUE non valida per ${table.key}');
            }
            fields.add(_columnFieldName(name));
          }
          uniqueKeys.add('[${fields.join(', ')}]');
        }
        _writeListGetter(
          tableClasses,
          'List<SchemaColumn>',
          'uniqueKeys',
          uniqueKeys,
          multiline: true,
        );
      }
      if (metadata.customConstraints.isNotEmpty) {
        _writeListGetter(
          tableClasses,
          'String',
          'customConstraints',
          metadata.customConstraints.map(_dartString),
        );
      }
      tableClasses
        ..writeln('}')
        ..writeln();
    }
    source
      ..writeln('}')
      ..writeln()
      ..write(tableClasses);
    return '${source.toString().trimRight()}\n';
  }
  throw const FormatException('Oggetto tables mancante, vuoto o non valido');
}

String _checkArgument(List<SchemaCheck> checks) {
  final expressions = [
    for (final check in checks)
      if (check.column case final String column)
        'SchemaCheck.column(SchemaCheckOperator.${check.operator.name}, ${_dartString(column)})'
      else
        'SchemaCheck.value(SchemaCheckOperator.${check.operator.name}, ${switch (check.value) {
          final String value => _dartString(value),
          final Object value => value.toString(),
          null => throw const FormatException('Valore CHECK mancante'),
        }})',
  ];
  final inline = 'constraints: const [${expressions.join(', ')}]';
  return inline.length <= 95
      ? inline
      : "constraints: const [\n      ${expressions.join(',\n      ')},\n    ]";
}

void _writeListGetter(
  StringBuffer source,
  String type,
  String name,
  Iterable<String> fields, {
  bool multiline = false,
}) {
  final getter = '  List<$type> get $name =>';
  final list = "$getter [${fields.join(', ')}];";
  source
    ..writeln()
    ..writeln('  @override');
  if (!multiline && list.length <= 100) {
    source.writeln(list);
  } else {
    source
      ..writeln('$getter [')
      ..writeln("    ${fields.join(',\n    ')},")
      ..writeln('  ];');
  }
}

String _generateMigration(List<int> versions) {
  final source = StringBuffer()
    ..writeln('// Generato dalle versioni in drift_schemas/.')
    ..writeln()
    ..writeln("import 'package:drift/drift.dart';");
  final parameters = StringBuffer();
  final calls = StringBuffer();
  if (versions.length > 1) {
    final importVersions = versions.map((version) => version.toString()).toList()..sort();
    for (final version in importVersions) {
      source.writeln(
        "import 'package:server/api/database/schema_v$version.dart' show SchemaV$version;",
      );
    }
    for (var index = 1; index < versions.length; index++) {
      final previous = versions[index - 1];
      final next = versions[index];
      final name = 'migrateFrom${previous}To$next';
      parameters.writeln(
        '  required Future<void> Function(SchemaV$previous from, SchemaV$next to) $name,',
      );
      calls
        ..writeln('    if (from <= $previous && to >= $next) {')
        ..writeln('      await $name(SchemaV$previous(), SchemaV$next());')
        ..writeln('    }');
    }
  }

  source.writeln();
  source.write('''
const schemaVersions = <int>[${versions.join(', ')}];
const firstSchemaVersion = ${versions.first};
const latestSchemaVersion = ${versions.last};

Future<void> migrateSchema(
  GeneratedDatabase database, {
$parameters  int from = firstSchemaVersion,
  int to = latestSchemaVersion,
}) async {
  if (!schemaVersions.contains(from) || !schemaVersions.contains(to) || from > to) {
    throw ArgumentError('Intervallo di migrazione non valido: \$from → \$to');
  }
''');
  if (versions.length > 1) {
    source.write('''
  if (from == to) return;

  await database.transaction(() async {
$calls  });
''');
  }
  return (source..writeln('}')).toString();
}

String _columnFieldName(String name) {
  final pascal = _pascalCase(name);
  if (pascal.isEmpty) return '';
  final field = pascal[0].toLowerCase() + pascal.substring(1);
  const aliases = {'name': 'nameColumn'};
  return aliases[field] ?? field;
}

String _pascalCase(String name) =>
    RegExp('[a-zA-Z0-9]+')
        .allMatches(name)
        .map((match) => match[0]!)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();

String _dartString(String value) {
  final encoded = jsonEncode(value).replaceAll(r'$', r'\$');
  if (value.contains("'")) return encoded;
  return "'${encoded.substring(1, encoded.length - 1).replaceAll(r'\"', '"')}'";
}
