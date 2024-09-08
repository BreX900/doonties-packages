import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

mixin DataClassEquatable {
  @protected
  Map<String, Object?> get props;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DataClassEquatable &&
            runtimeType == other.runtimeType &&
            _equality.equals(props.values, other.props.values);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll(props.values);

  @override
  String toString() {
    final b = StringBuffer(runtimeType);
    b.write('(');
    b.writeln();
    props.forEach((name, value) {
      b.write('  ');
      b.write(name);
      b.write(': ');
      b.write(value is String ? "'$value'" : value);
      b.write(',');
      b.writeln();
    });
    b.write(')');
    return b.toString();
  }
}

const _equality = IterableEquality(_Equality());

class _Equality implements Equality<Object?> {
  const _Equality();

  @override
  bool equals(Object? e1, Object? e2) {
    if (e1 is Set) {
      return e2 is Set && SetEquality(this).equals(e1, e2);
    }
    if (e1 is Map) {
      return e2 is Map && MapEquality(keys: this, values: this).equals(e1, e2);
    }
    if (e1 is List) {
      return e2 is List && ListEquality(this).equals(e1, e2);
    }
    return e1 == e2;
  }

  @override
  int hash(Object? e) => throw UnimplementedError();

  @override
  bool isValidKey(Object? o) => throw UnimplementedError();
}
