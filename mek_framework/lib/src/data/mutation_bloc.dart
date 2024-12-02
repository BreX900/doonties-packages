import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/core/typedefs.dart';
import 'package:mek/src/data/mutation_state.dart';
import 'package:mek/src/data/views.dart';
import 'package:mek/src/riverpod/adapters/state_notifier_provider.dart';
import 'package:mek/src/riverpod/auto_dispose_extension.dart';
import 'package:mek/src/riverpod/state_notifier_extensions.dart';
import 'package:meta/meta.dart';

typedef StartMutationListener<Arg> = FutureOr<void> Function(Arg arg);
typedef WillStartMutationListener<Arg> = FutureOr<bool?> Function(Arg arg);
typedef ErrorMutationListener<Arg> = FutureOr<void> Function(Arg arg, Object error);
typedef DataMutationListener<Arg, Result> = FutureOr<void> Function(Arg arg, Result result);
typedef ResultMutationListener<Arg, Result> = FutureOr<void> Function(
    Arg arg, Object? error, Result? result);

extension MutationBlocExtension on WidgetRef {
  MutationBloc<A, R> mutation<A, R>(
    Future<R> Function(MutationRef<R> ref, A arg) mutator, {
    StartMutationListener<A>? onStart,
    WillStartMutationListener<A>? onWillMutate,
    ErrorMutationListener<A>? onError = _sentinelError,
    @Deprecated('In favour of onSuccess') DataMutationListener<A, R>? onData,
    DataMutationListener<A, R>? onSuccess,
    ResultMutationListener<A, R>? onFinish,
  }) {
    final mutation = MutationBloc<A, R>(
      this,
      mutator,
      onStart: onStart,
      onWillMutate: onWillMutate,
      onError: onError == _sentinelError ? _listenError : onError,
      onData: onSuccess ?? onData,
      onFinish: onFinish,
    );
    onDispose(mutation.dispose);
    return mutation;
  }

  void listenMutation<A, R>(
    MutationBloc<A, R> bloc, {
    ListenerCondition<MutationState<R>>? when,
    void Function()? idle,
    void Function()? loading,
    void Function(Object error)? failed,
    void Function(R data)? success,
  }) {
    listen(bloc.provider, (previous, next) {
      if (previous != null && when != null && !when(previous, next)) return;
      next.whenOrNull<void>(
        idle: idle,
        loading: loading,
        failed: failed,
        success: success,
      );
    });
  }

  void listenManualMutation<A, R>(
    MutationBloc<A, R> bloc, {
    bool fireImmediately = false,
    ListenerCondition<MutationState<R>>? when,
    void Function()? idle,
    void Function()? loading,
    void Function(Object error)? failed,
    void Function(R data)? success,
  }) {
    listenManual(fireImmediately: fireImmediately, bloc.provider, (previous, next) {
      if (when != null && !when(previous!, next)) return;
      next.whenOrNull<void>(
        idle: idle,
        loading: loading,
        failed: failed,
        success: success,
      );
    });
  }

  static void _sentinelError(void arg, void error) {}

  void _listenError(void arg, Object error) => DataBuilders.listenError(context, error);
}

class MutationBloc<TArg, TResult> extends StateNotifier<MutationState<TResult>> {
  final WidgetRef _ref;
  final FutureOr<TResult> Function(MutationRef<TResult> ref, TArg arg) _mutator;
  final StartMutationListener<TArg>? _onStart;
  final WillStartMutationListener<TArg>? _onWillMutate;
  final ErrorMutationListener<TArg>? _onError;
  final DataMutationListener<TArg, TResult>? _onData;
  final ResultMutationListener<TArg, TResult>? _onFinish;

  MutationBloc(
    this._ref,
    this._mutator, {
    StartMutationListener<TArg>? onStart,
    WillStartMutationListener<TArg>? onWillMutate,
    ErrorMutationListener<TArg>? onError,
    DataMutationListener<TArg, TResult>? onData,
    ResultMutationListener<TArg, TResult>? onFinish,
  })  : _onStart = onStart,
        _onWillMutate = onWillMutate,
        _onError = onError,
        _onData = onData,
        _onFinish = onFinish,
        super(IdleMutation<TResult>());

  // ignore: discarded_futures
  void call(TArg arg) => run(arg);

  Future<void> run(TArg arg) async {
    if (!mounted) throw StateError("Can't mutate if bloc is closed!");

    if (state.args.contains(arg)) {
      lg.info('Bloc is mutating! $this');
      return;
    }

    if (!(await _onWillMutate?.call(arg) ?? true)) return;

    emit(state.toLoading(arg: arg));

    await _tryCall1(_onStart, arg);

    final ref = MutationRef._(_ref, this);
    try {
      final result = await _mutator(ref, arg);
      ref._dispose();

      if (!mounted) {
        lg.info('Bloc is closed! Cant emit success state. $this');
        return;
      }

      await _tryCall2(_onData, arg, result);
      await _tryCall3(_onFinish, arg, null, result);

      emit(state.toSuccess(arg: arg, data: result));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      ref._dispose();

      if (!mounted) {
        lg.info('Bloc is closed!  Cant emit failed state. $this');
        return;
      }

      await _tryCall2(_onError, arg, error);
      await _tryCall3(_onFinish, arg, error, null);

      emit(state.toFailed(arg: arg, error: error));

      rethrow;
    }
  }

  void updateProgress(double value) {
    if (state is! LoadingMutation<TResult>) {
      lg.info("Bloc isn't mutating! Cant update progress state. $this");
      return;
    }
    emit(state.toLoading(arg: state.args.single, progress: value));
  }

  FutureOr<void> _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
    if (fn == null) return;
    try {
      await fn($1);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  FutureOr<void> _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
    if (fn == null) return;
    try {
      await fn($1, $2);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  FutureOr<void> _tryCall3<T1, T2, T3>(
    FutureOr<void> Function(T1, T2, T3)? fn,
    T1 $1,
    T2 $2,
    T3 $3,
  ) async {
    if (fn == null) return;
    try {
      await fn($1, $2, $3);
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  @override
  String toString() => 'MutationBloc($_mutator)';
}

@optionalTypeArgs
class MutationRef<R> {
  WidgetRef? _ref;
  MutationBloc<void, R>? _bloc;

  MutationRef._(this._ref, this._bloc);

  MutationBloc<void, R> get bloc => _get(_bloc);

  ProviderContainer get container => ProviderScope.containerOf(_get(_ref).context, listen: false);

  bool exists(ProviderBase<Object?> provider) => _get(_ref).exists(provider);

  void invalidate(ProviderOrFamily provider) => _get(_ref).invalidate(provider);

  T read<T>(ProviderListenable<T> provider) => _get(_ref).read(provider);

  T refresh<T>(Refreshable<T> provider) => _get(_ref).refresh(provider);

  void updateProgress(double value) => _get(_bloc).updateProgress(value);

  T _get<T>(T? v) {
    if (v == null) throw StateError('Is disposed');
    return v;
  }

  void _dispose() {
    _ref = null;
    _bloc = null;
  }
}
