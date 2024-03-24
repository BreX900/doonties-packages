import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek_data_class/mek_data_class.dart';

part 'mutation_bloc.g.dart';

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

typedef ErrorAsyncListener = FutureOr<void> Function(Object error);
typedef DataAsyncListener<T> = FutureOr<void> Function(T result);
typedef ResultAsyncListener<T> = FutureOr<void> Function(Object? error, T? result);

typedef Mutation<T> = FutureOr<T> Function(Ref ref);
typedef MutationCallback = Future<void> Function();

class MutatorBloc<T> extends Cubit<MutationState<T>> {
  final SharedMutatingBloc _mutatorGroupBloc;
  final Ref _ref;

  StreamSubscription<void>? _mutableBlocSub;

  MutatorBloc(this._mutatorGroupBloc, this._ref) : super(IdleMutation<T>()) {
    _listenMutableBloc();
  }

  Future<void> call<R extends T>({
    void Function()? onStart,
    required Mutation<R> mutation,
    ErrorAsyncListener? onError,
    DataAsyncListener<R>? onData,
    ResultAsyncListener<R>? onFinish,
  }) async {
    if (isClosed) throw StateError('Cant mutate if bloc is closed!');

    if (state.isMutating) {
      lg.info('Bloc is mutating! $this');
      return;
    }

    await _mutableBlocSub?.cancel();
    _mutatorGroupBloc.notifyMutating();
    emit(state.toLoading());

    await _tryCall(onStart);

    try {
      final result = await mutation(_ref);

      if (isClosed) {
        lg.info('Bloc is closed! $this');
        return;
      }

      await _tryCall1(onData, result);
      await _tryCall2(onFinish, null, result);

      emit(state.toSuccess(data: result));
    } catch (error, stackTrace) {
      addError(error, stackTrace);

      if (isClosed) {
        lg.info('Bloc is closed! $this');
        return;
      }

      await _tryCall1(onError, error);
      await _tryCall2(onFinish, error, null);

      emit(state.toFailed(error: error));
    } finally {
      _mutatorGroupBloc.notifyMutated();
      _listenMutableBloc();
    }
  }

  void _listenMutableBloc() {
    _mutableBlocSub = _mutatorGroupBloc.stream.listen((isMutating) {
      if (isClosed) return;
      emit(state.copyWith(isMutating: isMutating));
    });
  }

  FutureOr<void> _tryCall(FutureOr<void> Function()? fn) async {
    if (fn == null) return;
    try {
      await fn();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  FutureOr<void> _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $0) async {
    if (fn == null) return;
    try {
      await fn($0);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  FutureOr<void> _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $0, T2 $1) async {
    if (fn == null) return;
    try {
      await fn($0, $1);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  Future<void> close() {
    unawaited(_mutableBlocSub?.cancel());
    return super.close();
  }
}

class SharedMutatingBloc extends Cubit<bool> {
  SharedMutatingBloc() : super(false);

  void notifyMutating() {
    if (isClosed) return;
    assert(!state, 'Cant run more than on mutation at the same time!');
    emit(true);
  }

  void notifyMutated() {
    if (isClosed) return;
    emit(false);
  }
}
