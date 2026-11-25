/// A table in a versioned Drift schema.
abstract class SchemaTable {
  const SchemaTable();

  String get name;
  List<SchemaColumn> get columns;
  List<SchemaColumn> get primaryKey;
  List<List<SchemaColumn>> get uniqueKeys => const [];
  List<String> get customConstraints => const [];
}

class SchemaReference {
  final String tableName;
  final String name;

  const SchemaReference({required this.tableName, required this.name});
}

/// Column metadata from a versioned Drift schema.
final class SchemaColumn extends SchemaReference {
  final SchemaColumnType type;
  final bool nullable;
  final bool autoIncrement;
  final SchemaReference? foreignKey;
  final List<SchemaCheck> constraints;
  final String? customConstraints;

  /// The default expression recorded by Drift, if any.
  final String? defaultValue;

  const SchemaColumn({
    required super.tableName,
    required super.name,
    required this.type,
    this.nullable = false,
    this.autoIncrement = false,
    this.defaultValue,
    this.foreignKey,
    this.customConstraints,
    this.constraints = const [],
  });
}

enum SchemaCheckOperator {
  lessThan('<'),
  lessOrEqual('<='),
  greaterThan('>'),
  greaterOrEqual('>='),
  equal('=');

  final String sql;
  const SchemaCheckOperator(this.sql);
}

final class SchemaCheck {
  final SchemaCheckOperator operator;
  final Object? value;
  final String? column;

  const SchemaCheck.value(this.operator, Object this.value) : column = null;
  const SchemaCheck.column(this.operator, String this.column) : value = null;
}

enum SchemaColumnType {
  boolean('bool'),
  doublePrecision('double'),
  integer('int'),
  numeric('numeric'),
  text('string'),
  date('PgTypes.date'),
  jsonb('PgTypes.jsonb'),
  timestampWithoutTimeZone('PgTypes.timestampNoTimezone');

  final String driftName;

  const SchemaColumnType(this.driftName);
}
