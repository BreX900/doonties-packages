import 'package:collection/collection.dart';

mixin DataClassEquatable {
  Map<String, Object> get props;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DataClassEquatable &&
            runtimeType == other.runtimeType &&
            _equality.equals(props.values, other.props.values);
  }

  @override
  int get hashCode => runtimeType.hashCode ^ Object.hashAll(props.values);

  // @override
  // String toString() {
  //   final classToString = '$runtimeType';
  //   props.forEach(classToString.add);
  //   return classToString.toString();
  // }
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
