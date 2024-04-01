import 'package:mek_data_class/mek_data_class.dart';

part 'mutation_state.g.dart';

sealed class MutationState<TData> {
  const MutationState._();

  bool get isMutating;

  bool get isIdle => this is IdleMutation<TData>;
  bool get isLoading => this is LoadingMutation<TData>;
  bool get isFailed => this is FailedMutation<TData>;
  bool get isSuccess => this is SuccessMutation<TData>;

  Object? get errorOrNull => whenOrNull(failed: (error) => error);

  const factory MutationState.idle() = IdleMutation<TData>;
  const factory MutationState.loading({double? progress}) = LoadingMutation<TData>;
  const factory MutationState.failed({required Object error}) = FailedMutation<TData>;
  const factory MutationState.success({required TData data}) = SuccessMutation<TData>;

  MutationState<TData> toIdle({bool isMutating = false}) => IdleMutation(isMutating: isMutating);

  MutationState<TData> toLoading({double? progress}) => LoadingMutation<TData>(progress: progress);

  MutationState<TData> toFailed({
    bool isMutating = false,
    required Object error,
  }) {
    return FailedMutation(isMutating: isMutating, error: error);
  }

  MutationState<TData> toSuccess({
    bool isMutating = false,
    required TData data,
  }) {
    return SuccessMutation(isMutating: isMutating, data: data);
  }

  MutationState<TData> copyWith({required bool isMutating});

  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    final state = this;
    return switch (state) {
      IdleMutation<TData>() => idle(state),
      LoadingMutation<TData>() => loading(state),
      FailedMutation<TData>() => failed(state),
      SuccessMutation<TData>() => success(state),
    };
  }

  R maybeMap<R>({
    R Function(IdleMutation<TData> state)? idle,
    R Function(LoadingMutation<TData> state)? loading,
    R Function(FailedMutation<TData> state)? failed,
    R Function(SuccessMutation<TData> state)? success,
    required R Function(MutationState<TData>) orElse,
  }) {
    return map(
      idle: idle ?? orElse,
      loading: loading ?? orElse,
      failed: failed ?? orElse,
      success: success ?? orElse,
    );
  }

  R? mapOrNull<R>({
    R Function(IdleMutation<TData> state)? idle,
    R Function(LoadingMutation<TData> state)? loading,
    R Function(FailedMutation<TData> state)? failed,
    R Function(SuccessMutation<TData> state)? success,
  }) {
    R? orNull(_) => null;
    return map(
      idle: idle ?? orNull,
      loading: loading ?? orNull,
      failed: failed ?? orNull,
      success: success ?? orNull,
    );
  }

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(Object error) failed,
    required R Function(TData data) success,
  }) {
    return map(
      idle: (state) => idle(),
      loading: (state) => loading(),
      failed: (state) => failed(state.error),
      success: (state) => success(state.data),
    );
  }

  R maybeWhen<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(Object error)? failed,
    R Function(TData data)? success,
    required R Function() orElse,
  }) {
    return map(
      idle: (_) => idle == null ? orElse() : idle(),
      loading: (_) => loading == null ? orElse() : loading(),
      failed: (state) => failed == null ? orElse() : failed(state.error),
      success: (state) => success == null ? orElse() : success(state.data),
    );
  }

  R? whenOrNull<R>({
    R Function()? idle,
    R Function()? loading,
    R Function(Object error)? failed,
    R Function(TData data)? success,
  }) {
    return map(
      idle: (_) => idle?.call(),
      loading: (_) => loading?.call(),
      failed: (state) => failed?.call(state.error),
      success: (state) => success?.call(state.data),
    );
  }
}

@DataClass()
class IdleMutation<TData> extends MutationState<TData> with _$IdleMutation<TData> {
  @override
  final bool isMutating;

  const IdleMutation({this.isMutating = false}) : super._();

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return idle(this);
  }

  @override
  MutationState<TData> copyWith({required bool isMutating}) => toIdle(isMutating: isMutating);
}

@DataClass()
class LoadingMutation<TData> extends MutationState<TData> with _$LoadingMutation<TData> {
  final double? progress;

  const LoadingMutation({this.progress}) : super._();

  @override
  bool get isMutating => true;

  @override
  MutationState<TData> copyWith({required bool isMutating}) => this;
}

@DataClass()
class FailedMutation<TData> extends MutationState<TData> with _$FailedMutation<TData> {
  @override
  final bool isMutating;

  final Object error;

  const FailedMutation({
    this.isMutating = false,
    required this.error,
  }) : super._();

  @override
  MutationState<TData> copyWith({required bool isMutating}) =>
      toFailed(error: error, isMutating: isMutating);
}

@DataClass()
class SuccessMutation<TData> extends MutationState<TData> with _$SuccessMutation<TData> {
  @override
  final bool isMutating;

  final TData data;

  const SuccessMutation({
    this.isMutating = false,
    required this.data,
  }) : super._();

  @override
  MutationState<TData> copyWith({required bool isMutating}) =>
      toSuccess(data: data, isMutating: false);
}
