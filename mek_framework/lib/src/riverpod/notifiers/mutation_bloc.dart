import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/core/typedefs.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:mek/src/riverpod/adapters/state_notifier_provider.dart';
import 'package:mek/src/riverpod/auto_dispose_extension.dart';
import 'package:mek/src/riverpod/notifiers/mutation_state.dart';
import 'package:mek/src/riverpod/state_notifier_extensions.dart';

extension MutationProviderListenableExtensions on ProviderListenable<MutationState<Object?>> {
  ProviderListenable<MutationState<Object?>?> of(Object? arg) => selectWith(arg, _of);

  static MutationState<Object?>? _of(Object? arg, MutationState<Object?> state) =>
      state.args.contains(arg) ? state : null;
}

extension MutationProviderListenableExtensions2 on ProviderListenable<MutationState<Object?>?> {
  ProviderListenable<bool> get isIdle => select(_isIdle);
  ProviderListenable<bool> get isMutating => select(_isMutating);

  static bool _isIdle(MutationState<Object?>? state) => state?.isIdle ?? true;
  static bool _isMutating(MutationState<Object?>? state) => state?.isMutating ?? false;
}

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
    required ErrorMutationListener<A>? onError,
    DataMutationListener<A, R>? onSuccess,
    ResultMutationListener<A, R>? onFinish,
  }) {
    final mutation = MutationBloc<A, R>(
      this,
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
    required StartMutationListener<TArg>? onStart,
    required WillStartMutationListener<TArg>? onWillMutate,
    required ErrorMutationListener<TArg>? onError,
    required DataMutationListener<TArg, TResult>? onData,
    required ResultMutationListener<TArg, TResult>? onFinish,
  })  : _onStart = onStart,
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
      lg.info('Bloc is mutating! $this');
      return;
    }

    if (!(await _onWillMutate?.call(arg) ?? true)) return;
    if (!mounted) return;

    emit(state.toLoading(arg: arg));

    await _tryCall1(_onStart, arg);
    if (!mounted) return;

    // ignore: use_build_context_synchronously
    final ref = MutationRef._(ProviderScope.containerOf(_ref.context, listen: false), this);
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

  void _ensureIsMounted() {
    if (!mounted) throw StateError("Can't mutate if bloc is closed!");
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
  final ProviderContainer _ref;
  MutationBloc<void, R>? _bloc;

  MutationRef._(this._ref, this._bloc);

  MutationBloc<void, R> get bloc => ArgumentError.checkNotNull(_bloc, 'MutationRef.bloc');

  bool exists(ProviderBase<Object?> provider) => _ref.exists(provider);

  void invalidate(ProviderOrFamily provider) => _ref.invalidate(provider);

  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  T refresh<T>(Refreshable<T> provider) => _ref.refresh(provider);

  void updateProgress(double value) => bloc.updateProgress(value);

  void _dispose() {
    _bloc = null;
  }
}
