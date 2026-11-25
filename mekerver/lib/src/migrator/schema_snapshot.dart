import 'package:mekerver/src/migrator/schema_table.dart';

final class SnapshotDatabase {
  final Map<String, SnapshotTable> tables;

  const SnapshotDatabase({required this.tables});

  factory SnapshotDatabase.fromJson(Map<Object?, Object?> json) {
    return SnapshotDatabase(
      tables: (json['tables']! as Map<Object?, Object?>).map((key, value) {
        return MapEntry(key as String, SnapshotTable.fromJson(value! as Map<Object?, Object?>));
      }),
    );
  }

  Map<String, Object?> toJson() => {
    'tables': {for (final table in tables.entries) table.key: table.value.toJson()},
  };
}

final class SnapshotColumn {
  final String type;
  final bool nullable;
  final String? defaultValue;
  final bool autoIncrement;
  final DriftSchemaForeignKey? foreignKey;
  final String? customConstraints;
  final List<SchemaCheck> constraints;

  const SnapshotColumn({
    required this.type,
    required this.nullable,
    this.defaultValue,
    this.autoIncrement = false,
    this.foreignKey,
    this.customConstraints,
    this.constraints = const [],
  });

  factory SnapshotColumn.fromJson(Map<Object?, Object?> json) {
    final key = json['foreignKey'] as Map<Object?, Object?>?;
    return SnapshotColumn(
      type: json['type']! as String,
      nullable: json['nullable'] as bool? ?? false,
      defaultValue: json['default'] as String?,
      autoIncrement: json['autoIncrement'] as bool? ?? false,
      foreignKey: key == null ? null : DriftSchemaForeignKey.fromJson(key),
      customConstraints: json['customConstraints'] as String?,
      constraints: (json['constraints'] as List<Object?>? ?? const []).map((data) {
        return _checkFromJson(data! as Map<Object?, Object?>);
      }).toList(),
    );
  }

  Map<String, Object?> toJson() => {
    'type': type,
    if (nullable) 'nullable': true,
    if (defaultValue != null) 'default': defaultValue,
    if (autoIncrement) 'autoIncrement': true,
    if (foreignKey != null) 'foreignKey': foreignKey!.toJson(),
    if (customConstraints != null) 'customConstraints': customConstraints,
    if (constraints.isNotEmpty)
      'constraints': [
        for (final check in constraints)
          {
            'type': 'check',
            'operator': check.operator.sql,
            if (check.column case final String column) 'column': column else 'value': check.value,
          },
      ],
  };
}

SchemaCheck _checkFromJson(Map<Object?, Object?> json) {
  final operator = SchemaCheckOperator.values.where((operator) => operator.sql == json['operator']);
  if (json['type'] != 'check' ||
      operator.isEmpty ||
      json.containsKey('column') == json.containsKey('value')) {
    throw const FormatException('Vincolo CHECK non valido');
  }
  if (json case {'column': final String column}) {
    return SchemaCheck.column(operator.single, column);
  }
  if (json case {'value': final num value}) {
    return SchemaCheck.value(operator.single, value);
  }
  if (json case {'value': final String value}) {
    return SchemaCheck.value(operator.single, value);
  }
  if (json case {'value': final bool value}) {
    return SchemaCheck.value(operator.single, value);
  }
  throw const FormatException('Operando CHECK non valido');
}

final class SnapshotTable {
  final Map<String, SnapshotColumn> columns;
  final List<String> primaryKey;
  final List<List<String>> uniqueKeys;
  final List<String> customConstraints;

  const SnapshotTable({
    required this.columns,
    required this.primaryKey,
    this.uniqueKeys = const [],
    this.customConstraints = const [],
  });

  factory SnapshotTable.fromJson(Map<Object?, Object?> json) {
    return SnapshotTable(
      columns: (json['columns']! as Map<Object?, Object?>).map((key, value) {
        return MapEntry(key as String, SnapshotColumn.fromJson(value! as Map<Object?, Object?>));
      }),
      primaryKey: (json['primaryKey']! as List<Object?>).cast<String>().toList(),
      uniqueKeys: (json['uniqueKeys'] as List<Object?>? ?? const []).map((keys) {
        return (keys as List<Object?>).cast<String>();
      }).toList(),
      customConstraints: (json['customConstraints'] as List<Object?>? ?? const [])
          .cast<String>()
          .toList(),
    );
  }

  Map<String, Object?> toJson() => {
    'primaryKey': primaryKey,
    if (uniqueKeys.isNotEmpty) 'uniqueKeys': uniqueKeys,
    if (customConstraints.isNotEmpty) 'customConstraints': customConstraints,
    'columns': {for (final column in columns.entries) column.key: column.value.toJson()},
  };
}

final class DriftSchemaForeignKey {
  final String referencedTable;
  final String referencedColumn;

  const DriftSchemaForeignKey({required this.referencedTable, required this.referencedColumn});

  factory DriftSchemaForeignKey.fromJson(Map<Object?, Object?> json) => DriftSchemaForeignKey(
    referencedTable: json['referencedTable']! as String,
    referencedColumn: json['referencedColumn']! as String,
  );

  Map<String, Object?> toJson() => {
    'referencedTable': referencedTable,
    'referencedColumn': referencedColumn,
  };
}
