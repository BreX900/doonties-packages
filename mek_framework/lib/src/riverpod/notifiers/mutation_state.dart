import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mekart/mekart.dart';

extension MutationProviderExtensions on ProviderListenable<MutationState<Object?>> {
  ProviderListenable<bool> get isIdle => select(_isIdle);

  @Deprecated('In favour of isPending')
  ProviderListenable<bool> get isMutating => select(_isMutating);
  ProviderListenable<bool> get isPending => select(_isMutating);

  static bool _isIdle(MutationState<Object?> state) => state.isIdle;

  static bool _isMutating(MutationState<Object?> state) => state.isPending;
}

sealed class MutationState<TData> with EquatableAndDescribable {
  final ISet<Object?> args;

  const MutationState({required this.args});

  bool get isIdle => this is MutationIdle<TData>;

  bool get isPending => this is MutationPending<TData>;

  bool get hasError => this is MutationError<TData>;

  bool get isSuccess => this is MutationSuccess<TData>;

  Object? get errorOrNull => whenOrNull(failed: (error) => error);

  double? get progressOrNull {
    final state = this;
    return state is MutationPending<TData> ? state.status.values.singleOrNull : null;
  }

  IMap<Object?, double?> get status {
    final state = this;
    return state is MutationPending<TData> ? state.status : const IMap.empty();
  }

  const factory MutationState.idle() = MutationIdle<TData>;

  const factory MutationState.pending() = MutationPending<TData>;

  const factory MutationState.loading({
    required ISet<Object?> args,
    required IMap<Object?, double?> status,
  }) = MutationPending<TData>;

  const factory MutationState.failed(Object error, StackTrace stackTrace, {ISet<Object?> args}) =
      MutationError<TData>;

  const factory MutationState.error(Object error, StackTrace stackTrace) = MutationError<TData>;

  const factory MutationState.success({required ISet<Object?> args, required TData data}) =
      MutationSuccess<TData>;

  MutationState<TData> toIdle() => MutationIdle<TData>();

  MutationState<TData> toLoading({required Object? arg, double? progress}) =>
      MutationPending<TData>(args: args.add(arg), status: status.add(arg, progress));

  MutationState<TData> toFailed({
    required Object? arg,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return MutationError(args: args.remove(arg), error, stackTrace);
  }

  MutationState<TData> toSuccess({required Object? arg, required TData data}) {
    return MutationSuccess(args: args.remove(arg), data: data);
  }

  R map<R>({
    required R Function(MutationIdle<TData> state) idle,
    required R Function(MutationPending<TData> state) loading,
    required R Function(MutationError<TData> state) failed,
    required R Function(MutationSuccess<TData> state) success,
  }) {
    final state = this;
    return switch (state) {
      MutationIdle<TData>() => idle(state),
      MutationPending<TData>() => loading(state),
      MutationError<TData>() => failed(state),
      MutationSuccess<TData>() => success(state),
    };
  }

  R maybeMap<R>({
    R Function(MutationIdle<TData> state)? idle,
    R Function(MutationPending<TData> state)? loading,
    R Function(MutationError<TData> state)? failed,
    R Function(MutationSuccess<TData> state)? success,
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
    R Function(MutationIdle<TData> state)? idle,
    R Function(MutationPending<TData> state)? loading,
    R Function(MutationError<TData> state)? failed,
    R Function(MutationSuccess<TData> state)? success,
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

typedef IdleMutation<TData> = MutationIdle<TData>;

class MutationIdle<TData> extends MutationState<TData> {
  const MutationIdle() : super(args: const ISet.empty());

  @override
  R map<R>({
    required R Function(MutationIdle<TData> state) idle,
    required R Function(MutationPending<TData> state) loading,
    required R Function(MutationError<TData> state) failed,
    required R Function(MutationSuccess<TData> state) success,
  }) {
    return idle(this);
  }
}

typedef LoadingMutation<TData> = MutationPending<TData>;

class MutationPending<TData> extends MutationState<TData> {
  @override
  final IMap<Object?, double?> status;

  const MutationPending({super.args = const ISet.empty(), this.status = const IMap.empty()});

  @override
  Map<String, Object?> get props => super.props..['status'] = status;
}

typedef FailedMutation<TData> = MutationError<TData>;

class MutationError<TData> extends MutationState<TData> {
  final Object error;
  final StackTrace stackTrace;

  const MutationError(this.error, this.stackTrace, {super.args = const ISet.empty()});

  @override
  Map<String, Object?> get props => super.props..['error'] = error;
}

typedef SuccessMutation<TData> = MutationSuccess<TData>;

class MutationSuccess<TData> extends MutationState<TData> {
  final TData data;

  const MutationSuccess({required super.args, required this.data});

  @override
  Map<String, Object?> get props => super.props..['data'] = data;
}
