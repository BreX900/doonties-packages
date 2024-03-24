import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class Either<L, R> {
  const Either();

  const factory Either.left(L value) = _Left<L, R>;
  const factory Either.right(R value) = _Right<L, R>;

  T when<T>(T Function(L value) left, T Function(R value) right);

  Future<Either<TL, TR>> whenAsync<TL, TR>(
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

class _Left<L, R> extends Either<L, R> with EquatableMixin {
  final L value;

  const _Left(this.value);

  @override
  T when<T>(T Function(L value) left, T Function(R value) right) => left(value);

  @override
  List<Object?> get props => [value];
}

class _Right<L, R> extends Either<L, R> with EquatableMixin {
  final R value;

  const _Right(this.value);

  @override
  T when<T>(T Function(L value) left, T Function(R value) right) => right(value);

  @override
  List<Object?> get props => [value];
}
