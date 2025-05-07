import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class Either<L, R> {
  const Either();

  L? get leftOrNull => when((left) => left, (_) => null);
  L? get rightOrNull => when((left) => left, (_) => null);

  bool get isLeft => when((_) => true, (_) => false);
  bool get isRight => when((_) => false, (_) => true);

  const factory Either.left(L value) = LeftEither<L, R>;
  const factory Either.right(R value) = RightEither<L, R>;

  T when<T>(T Function(L value) left, T Function(R value) right);

  Future<Either<TL, TR>> mapAsync<TL, TR>(
    FutureOr<TL> Function(L value) left,
    FutureOr<TR> Function(R value) right,
  ) {
    return when((value) async {
      return Either.left(await left(value));
    }, (value) async {
      return Either.right(await right(value));
    });
  }
}

class LeftEither<L, R> extends Either<L, R> with EquatableMixin {
  final L value;

  const LeftEither(this.value);

  @override
  T when<T>(T Function(L value) left, T Function(R value) right) => left(value);

  @override
  List<Object?> get props => [value];
}

class RightEither<L, R> extends Either<L, R> with EquatableMixin {
  final R value;

  const RightEither(this.value);

  @override
  T when<T>(T Function(L value) left, T Function(R value) right) => right(value);

  @override
  List<Object?> get props => [value];
}
