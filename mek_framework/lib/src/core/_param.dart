import 'package:meta/meta.dart';

@immutable
class Param<T> {
  final T value;

  const Param(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Param<T> && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '<$value>';
}
