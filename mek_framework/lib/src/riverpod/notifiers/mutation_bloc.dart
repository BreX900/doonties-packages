import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/riverpod/notifiers/_mutation.dart';

extension MutationProviderListenableExtensions on Source<MutationState<Object?>> {
  Source<MutationState<Object?>?> of(Object? arg) => selectWith(arg, _of);

  static MutationState<Object?>? _of(Object? arg, MutationState<Object?> state) =>
      state.args.contains(arg) ? state : null;
}

extension MutationProviderListenableExtensions2 on Source<MutationState<Object?>?> {
  Source<bool> get isIdle => select(_isIdle);
  Source<bool> get isMutating => select(_isMutating);

  static bool _isIdle(MutationState<Object?>? state) => state?.isIdle ?? true;
  static bool _isMutating(MutationState<Object?>? state) => state?.isMutating ?? false;
}

typedef StartMutationListener<Arg> = FutureOr<void> Function(Arg arg);
typedef WillStartMutationListener<Arg> = FutureOr<bool?> Function(Arg arg);
typedef ErrorMutationListener<Arg> = FutureOr<void> Function(Arg arg, Object error);
typedef DataMutationListener<Arg, Result> = FutureOr<void> Function(Arg arg, Result result);
typedef ResultMutationListener<Arg, Result> =
    FutureOr<void> Function(Arg arg, Object? error, Result? result);

extension MutationBlocExtension on ConsumerScope {
  MutationBloc<A, R> mutation<A, R>(
    Future<R> Function(MutationRef ref, A arg) mutator, {
    StartMutationListener<A>? onStart,
    WillStartMutationListener<A>? onWillMutate,
    required ErrorMutationListener<A>? onError,
    DataMutationListener<A, R>? onSuccess,
    ResultMutationListener<A, R>? onFinish,
  }) {
    final mutation = MutationBloc<A, R>(
      ref,
      mutator,
      onStart: onStart,
      onWillMutate: onWillMutate,
      onError: onError,
      onData: onSuccess,
      onFinish: onFinish,
    );
    onDispose(mutation.dispose);
    return mutation;
  }
}

class MutationBloc<TArg, TResult> extends SourceNotifier<MutationState<TResult>>
    implements Mutation<TArg> {
  final WidgetRef _ref;
  final FutureOr<TResult> Function(MutationRef ref, TArg arg) _mutator;
  final StartMutationListener<TArg>? _onStart;
  final WillStartMutationListener<TArg>? _onWillMutate;
  final ErrorMutationListener<TArg>? _onError;
  final DataMutationListener<TArg, TResult>? _onData;
  final ResultMutationListener<TArg, TResult>? _onFinish;

  MutationBloc(
    this._ref,
    this._mutator, {
    required StartMutationListener<TArg>? onStart,
    required WillStartMutationListener<TArg>? onWillMutate,
    required ErrorMutationListener<TArg>? onError,
    required DataMutationListener<TArg, TResult>? onData,
    required ResultMutationListener<TArg, TResult>? onFinish,
  }) : _onStart = onStart,
       _onWillMutate = onWillMutate,
       _onError = onError,
       _onData = onData,
       _onFinish = onFinish,
       super(IdleMutation<TResult>());

  // ignore: discarded_futures
  void call(TArg arg) => run(arg).ignore();

  Future<void> run(TArg arg) async {
    _ensureIsMounted();

    if (state.args.contains(arg)) {
      lg.info('$this is mutating!');
      return;
    }

    if (!(await _onWillMutate?.call(arg) ?? true)) return;
    if (!mounted) return;

    state = state.toLoading(arg: arg);

    await _tryCall1(_onStart, arg);
    if (!mounted) return;

    final ref = MutationRefImpl(_ref.container, this, arg);
    try {
      final result = await _mutator(ref, arg);
      ref.dispose();
      if (!mounted) return;

      await _tryCall2(_onData, arg, result);
      if (!mounted) return;

      await _tryCall3(_onFinish, arg, null, result);
      if (!mounted) return;

      state = state.toSuccess(arg: arg, data: result);
    } catch (error, stackTrace) {
      Source.observer.onUncaughtError(this, error, stackTrace);
      ref.dispose();
      if (!mounted) return;

      await _tryCall2(_onError, arg, error);
      if (!mounted) return;

      await _tryCall3(_onFinish, arg, error, null);
      if (!mounted) return;

      state = state.toFailed(arg: arg, error: error);

      rethrow;
    }
  }

  @override
  void updateProgress(TArg arg, double value) {
    if (state is! LoadingMutation<TResult>) {
      lg.info("Bloc isn't mutating! Cant update progress state. $this");
      return;
    }
    state = state.toLoading(arg: arg, progress: value);
  }

  void _ensureIsMounted() {
    if (!mounted) throw StateError("Can't mutate if bloc is closed!");
  }

  FutureOr<void> _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
    if (fn == null) return;
    try {
      await fn($1);
    } catch (error, stackTrace) {
      Source.observer.onUncaughtError(this, error, stackTrace);
    }
  }

  FutureOr<void> _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
    if (fn == null) return;
    try {
      await fn($1, $2);
    } catch (error, stackTrace) {
      Source.observer.onUncaughtError(this, error, stackTrace);
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
      Source.observer.onUncaughtError(this, error, stackTrace);
    }
  }

  @override
  String toString() => 'MutationBloc($_mutator)';
}
