import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:meker/src/migrator/schema_snapshot.dart';
import 'package:meker/src/migrator/schema_table.dart';
import 'package:yaml_codec/yaml_codec.dart';

const _moduleDirectory = '.dart_tool/build/generated/server/lib';
const _moduleSuffix = '.drift_module.json';
const _databaseModule = 'api/database/app_database.dart.drift_module.json';

final _yamlCodec = YamlCodec(toEncodable: (data) => (data as dynamic).toJson());

Future<void> exportSchema() async {
  final build = await Process.start('dart', [
    'run',
    'build_runner',
    'build',
  ], mode: ProcessStartMode.inheritStdio);
  final buildExitCode = await build.exitCode;
  if (buildExitCode != 0) {
    stderr.writeln('Build Drift fallita (codice $buildExitCode)');
    exit(buildExitCode);
  }

  final input = Directory(_moduleDirectory);
  final version = _readDatabaseVersion(File('${input.path}/$_databaseModule'));
  final snapshot = SnapshotDatabase(tables: _readTables(input));

  final output = File('drift_schemas/$version.yaml');

  output.parent.createSync(recursive: true);
  output.writeAsStringSync(_yamlCodec.encode(snapshot));

  stdout.writeln('${snapshot.tables.length} tabelle esportate in ${output.path}');
}

int _readDatabaseVersion(File file) {
  try {
    final module = jsonDecode(file.readAsStringSync());
    if (module case {'elements': {'AppDatabase': {'schema_version': final int version}}}
        when version > 0) {
      return version;
    }
    throw const FormatException('Versione dello schema mancante o non valida');
  } on FormatException catch (error) {
    throw FormatException('${file.path}: ${error.message}');
  }
}

Map<String, SnapshotTable> _readTables(Directory input) {
  final files =
      input
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => file.path.endsWith(_moduleSuffix))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final tables = SplayTreeMap<String, SnapshotTable>();
  final sources = <String, String>{};
  for (final file in files) {
    try {
      final module = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
      final elements = module['elements']! as Map<String, Object?>;
      for (final MapEntry(:key, :value) in elements.entries) {
        final element = value! as Map<String, Object?>;
        if (element['type'] != 'table') continue;

        final table = _readTable(key, element);
        final previous = tables[key];
        if (previous == null) {
          tables[key] = table;
          sources[key] = file.path;
        } else if (!const DeepCollectionEquality().equals(previous.toJson(), table.toJson())) {
          throw FormatException('Definizione di $key in conflitto con ${sources[key]}');
        }
      }
    } on FormatException catch (error) {
      throw FormatException('${file.path}: ${error.message}');
      // Report invalid generated metadata with the module path.
      // ignore: avoid_catching_errors
    } on TypeError catch (error) {
      throw FormatException('${file.path}: struttura del modulo Drift non valida ($error)');
    }
  }
  if (tables.isEmpty) {
    throw FormatException('Nessuna tabella trovata in ${input.path}');
  }
  return tables;
}

SnapshotTable _readTable(String tableName, Map<String, Object?> table) {
  final columns = (table['columns']! as List<Object?>).cast<Map<String, Object?>>();
  final sqlNames = {
    for (final column in columns) column['nameInDart']! as String: column['nameInSql']! as String,
  };
  final fields = <String, SnapshotColumn>{};
  final columnPrimaryKeys = <String>[];
  final uniqueKeys = <List<String>>[];
  final tableForeignKeys = <String, DriftSchemaForeignKey>{};
  List<String>? primaryKey;
  final constraints = (table['table_constraints']! as List<Object?>).cast<Map<String, Object?>>();
  for (final constraint in constraints) {
    switch (constraint) {
      case {'type': 'primary_key', 'columns': final List<Object?> names}:
        primaryKey = names.cast<String>();
      case {'type': 'unique', 'columns': final List<Object?> names}:
        uniqueKeys.add(names.cast<String>());
      case {
        'type': 'foreign',
        'local': final List<Object?> local,
        'foreign': final List<Object?> foreign,
      }:
        if (local.length != 1 || foreign.length != 1) {
          throw FormatException('Chiave esterna composta non supportata: ${local.join(', ')}');
        }
        final name = local.single! as String;
        if (tableForeignKeys.containsKey(name)) {
          throw FormatException('Più chiavi esterne per la colonna $name');
        }
        tableForeignKeys[name] = _readForeignKey(foreign.single! as Map<String, Object?>);
    }
  }
  for (final column in columns) {
    final name = column['nameInSql']! as String;
    final defaultArgument = column['defaultArgument'] as Map<String, Object?>?;
    final customConstraints = column['customConstraints'] as String?;
    Map<String, Object?>? checkExpression;
    var autoIncrement = false;
    var foreignKey = tableForeignKeys.remove(name);
    final constraints = (column['constraints']! as List<Object?>).cast<Map<String, Object?>>();
    for (final constraint in constraints) {
      if (constraint case {'type': 'primary', 'is_auto_increment': final bool auto}) {
        columnPrimaryKeys.add(name);
        autoIncrement = auto;
      }
      if (constraint['type'] == 'unique') {
        uniqueKeys.add([name]);
      }
      if (constraint case {
        'type': 'check',
        'dart_expression': final Map<String, Object?> expression,
      }) {
        // Drift's generated column keeps the last Dart check.
        checkExpression = expression;
      }
      if (constraint case {'type': 'foreign_key', 'column': final Map<String, Object?> target}) {
        if (foreignKey != null) {
          throw FormatException('Più chiavi esterne per la colonna $name');
        }
        foreignKey = _readForeignKey(target);
      }
    }
    fields[name] = SnapshotColumn(
      type: _readType(column['sqlType']! as Map<String, Object?>),
      nullable: column['nullable']! as bool,
      defaultValue: defaultArgument == null ? null : _readExpression(defaultArgument),
      autoIncrement: autoIncrement,
      foreignKey: foreignKey,
      customConstraints: customConstraints,
      constraints: [
        if (checkExpression != null && customConstraints == null)
          _readCheck(
            checkExpression,
            '$tableName.$name',
            column['nameInDart']! as String,
            sqlNames,
          ),
      ],
    );
  }
  if (tableForeignKeys.isNotEmpty) {
    throw FormatException('Colonna sconosciuta: ${tableForeignKeys.keys.first}');
  }
  return SnapshotTable(
    columns: fields,
    primaryKey: primaryKey ?? columnPrimaryKeys,
    uniqueKeys: uniqueKeys,
    customConstraints: (table['custom_constraints'] as List<Object?>? ?? const []).cast<String>(),
  );
}

final _comparisonPattern = RegExp(r'^(?:ComparableExpr\((\w+)\)|(\w+))\.(\w+)\(([\s\S]*)\)$');
final _customNumberPattern = RegExp(
  r'''^(?:const )?CustomExpression\(['"]([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?)['"]\)$''',
);
final _textLiteralPattern = RegExp(r'''^(['"])([^\\$]*)\1$''');

SchemaCheck _readCheck(
  Map<String, Object?> expression,
  String field,
  String dartName,
  Map<String, String> sqlNames,
) {
  final code = _readExpression(expression);
  final match = _comparisonPattern.firstMatch(code);
  if (match != null && (match[1] ?? match[2]) == dartName) {
    final method = match[3]!;
    final operator = switch (method) {
      'isBiggerThan' || 'isBiggerThanValue' => SchemaCheckOperator.greaterThan,
      'isBiggerOrEqual' || 'isBiggerOrEqualValue' => SchemaCheckOperator.greaterOrEqual,
      'isSmallerThan' || 'isSmallerThanValue' => SchemaCheckOperator.lessThan,
      'isSmallerOrEqual' || 'isSmallerOrEqualValue' => SchemaCheckOperator.lessOrEqual,
      'equals' || 'equalsExp' => SchemaCheckOperator.equal,
      _ => null,
    };
    final target = match[4]!.trim();
    if (operator != null) {
      if (method.endsWith('Value') || method == 'equals') {
        final value = num.tryParse(target);
        final text = _textLiteralPattern.firstMatch(target);
        if (value != null && value.isFinite) return SchemaCheck.value(operator, value);
        if (text != null && !text[2]!.contains(text[1]!)) {
          return SchemaCheck.value(operator, text[2]!);
        }
        if (target == 'true' || target == 'false') {
          return SchemaCheck.value(operator, target == 'true');
        }
      } else {
        final column = sqlNames[target];
        if (column != null) return SchemaCheck.column(operator, column);
        final rawNumber = _customNumberPattern.firstMatch(target);
        final value = rawNumber == null ? null : num.tryParse(rawNumber[1]!);
        if (value != null && value.isFinite) return SchemaCheck.value(operator, value);
      }
    }
  }
  throw FormatException('CHECK Dart non supportato per $field: $code');
}

DriftSchemaForeignKey _readForeignKey(Map<String, Object?> target) {
  final table = target['table']! as Map<String, Object?>;
  return DriftSchemaForeignKey(
    referencedTable: table['name']! as String,
    referencedColumn: target['name']! as String,
  );
}

String _readType(Map<String, Object?> sqlType) {
  if (sqlType['builtin'] case final String type) return type;
  final custom = sqlType['custom']! as Map<String, Object?>;
  final type = _readExpression(custom['expression']! as Map<String, Object?>);
  return type == 'const NumericType()' ? 'numeric' : type;
}

String _readExpression(Map<String, Object?> expression) {
  final parts = expression['elements']! as List<Object?>;
  return parts
      .map((part) => part is String ? part : (part! as Map<String, Object?>)['lexeme']! as String)
      .join()
      .trim();
}
