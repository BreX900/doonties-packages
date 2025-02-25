import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mekart/mekart.dart';

sealed class MutationState<TData> with EquatableAndDescribable {
  final ISet<Object?> args;

  const MutationState({required this.args});

  bool get isMutating => args.isNotEmpty;

  bool get isIdle => this is IdleMutation<TData>;
  bool get isLoading => this is LoadingMutation<TData>;
  bool get isFailed => this is FailedMutation<TData>;
  bool get isSuccess => this is SuccessMutation<TData>;

  Object? get errorOrNull => whenOrNull(failed: (error) => error);

  double? get progressOrNull {
    final state = this;
    return state is LoadingMutation<TData> ? state.progress : null;
  }

  const factory MutationState.idle() = IdleMutation<TData>;
  const factory MutationState.loading({required ISet<Object?> args, double? progress}) =
      LoadingMutation<TData>;
  const factory MutationState.failed({required ISet<Object?> args, required Object error}) =
      FailedMutation<TData>;
  const factory MutationState.success({required ISet<Object?> args, required TData data}) =
      SuccessMutation<TData>;

  MutationState<TData> toIdle() => IdleMutation<TData>();

  MutationState<TData> toLoading({required Object? arg, double? progress}) =>
      LoadingMutation<TData>(args: args.add(arg), progress: progress);

  MutationState<TData> toFailed({
    required Object? arg,
    required Object error,
  }) {
    return FailedMutation(args: args.remove(arg), error: error);
  }

  MutationState<TData> toSuccess({
    required Object? arg,
    required TData data,
  }) {
    return SuccessMutation(args: args.remove(arg), data: data);
  }

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

  @override
  Map<String, Object?> get props => {'args': args};
}

class IdleMutation<TData> extends MutationState<TData> {
  const IdleMutation() : super(args: const ISet.empty());

  @override
  R map<R>({
    required R Function(IdleMutation<TData> state) idle,
    required R Function(LoadingMutation<TData> state) loading,
    required R Function(FailedMutation<TData> state) failed,
    required R Function(SuccessMutation<TData> state) success,
  }) {
    return idle(this);
  }
}

class LoadingMutation<TData> extends MutationState<TData> {
  final double? progress;

  const LoadingMutation({required super.args, this.progress});

  @override
  Map<String, Object?> get props => super.props..['progress'] = progress;
}

class FailedMutation<TData> extends MutationState<TData> {
  final Object error;

  const FailedMutation({required super.args, required this.error});

  @override
  Map<String, Object?> get props => super.props..['error'] = error;
}

class SuccessMutation<TData> extends MutationState<TData> {
  final TData data;

  const SuccessMutation({required super.args, required this.data});

  @override
  Map<String, Object?> get props => super.props..['data'] = data;
}
