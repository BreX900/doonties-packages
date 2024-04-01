// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mutation_state.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$IdleMutation<TData> {
  IdleMutation<TData> get _self => this as IdleMutation<TData>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdleMutation<TData> &&
          runtimeType == other.runtimeType &&
          _self.isMutating == other.isMutating;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isMutating.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() =>
      (ClassToString('IdleMutation', [TData])..add('isMutating', _self.isMutating)).toString();
}

mixin _$LoadingMutation<TData> {
  LoadingMutation<TData> get _self => this as LoadingMutation<TData>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingMutation<TData> &&
          runtimeType == other.runtimeType &&
          _self.progress == other.progress;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.progress.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() =>
      (ClassToString('LoadingMutation', [TData])..add('progress', _self.progress)).toString();
}

mixin _$FailedMutation<TData> {
  FailedMutation<TData> get _self => this as FailedMutation<TData>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailedMutation<TData> &&
          runtimeType == other.runtimeType &&
          _self.isMutating == other.isMutating &&
          _self.error == other.error;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isMutating.hashCode);
    hashCode = $hashCombine(hashCode, _self.error.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('FailedMutation', [TData])
        ..add('isMutating', _self.isMutating)
        ..add('error', _self.error))
      .toString();
}

mixin _$SuccessMutation<TData> {
  SuccessMutation<TData> get _self => this as SuccessMutation<TData>;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessMutation<TData> &&
          runtimeType == other.runtimeType &&
          _self.isMutating == other.isMutating &&
          _self.data == other.data;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.isMutating.hashCode);
    hashCode = $hashCombine(hashCode, _self.data.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('SuccessMutation', [TData])
        ..add('isMutating', _self.isMutating)
        ..add('data', _self.data))
      .toString();
}
