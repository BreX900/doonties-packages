import 'package:meta/meta.dart';

@immutable
class Optional<T> {
  final T value;

  const Optional(this.value);

  @override
  String toString() => 'Optional($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Optional && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

extension RequireOptionalExtension<T> on Optional<T>? {
  T get requireValue {
    final instance = this;
    if (instance == null) throw StateError('The Optional<$T> is null!');
    return instance.value;
  }
}
