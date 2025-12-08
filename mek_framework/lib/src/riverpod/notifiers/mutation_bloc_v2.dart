import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/riverpod/notifiers/_mutation.dart';

extension MutationNotififierExtension on SourceRef {
  MutationNotifier<A, R> mutationV2<A, R>(Future<R> Function(MutationRef ref, A arg) mutator) {
    final mutation = MutationNotifier<A, R>(
      () => ProviderScope.containerOf(context, listen: false),
      mutator,
    );
    onDispose(mutation.dispose);
    return mutation;
  }
}

typedef ErrorMutationListenerV2 = FutureOr<void> Function(Object error);
typedef DataMutationListenerV2<Result> = FutureOr<void> Function(Result result);
typedef ResultMutationListenerV2<Result> = FutureOr<void> Function(Object? error, Result? result);

class MutationNotifier<TArg, TResult> extends SourceNotifier<MutationState<TResult>>
    implements Mutation<TArg> {
  final ProviderContainer Function() _readContainer;
  final Future<TResult> Function(MutationRef ref, TArg arg) _mutator;

  MutationNotifier(this._readContainer, this._mutator) : super(IdleMutation<TResult>());

  void call(
    TArg arg, {
    required ErrorMutationListenerV2? onError,
    DataMutationListenerV2<TResult>? onSuccess,
    ResultMutationListenerV2<TResult>? onSettled,
  }) => unawaited(execute(arg, onError: onError, onSuccess: onSuccess, onSettled: onSettled));

  Future<bool?> execute(
    TArg arg, {
    required ErrorMutationListenerV2? onError,
    DataMutationListenerV2<TResult>? onSuccess,
    ResultMutationListenerV2<TResult>? onSettled,
  }) async {
    try {
      await run(arg, onError: onError, onSuccess: onSuccess, onSettled: onSettled);
      if (!mounted) return null;
      return true;
    } catch (error, stackTrace) {
      if (!mounted) return null;
      SourceObserver.current.onUncaughtError(this, error, stackTrace);
      return false;
    }
  }

  Future<TResult> run(
    TArg arg, {
    ErrorMutationListenerV2? onError,
    DataMutationListenerV2<TResult>? onSuccess,
    ResultMutationListenerV2<TResult>? onSettled,
  }) async {
    if (!mounted) throw StateError("Can't mutate if bloc is closed!");

    state = state.toLoading(arg: arg);

    final ref = MutationRefImpl(_readContainer(), this, arg);
    try {
      final result = await _mutator(ref, arg);
      ref.dispose();
      if (!mounted) return result;

      unawaited(_tryCall1(onSuccess, result));
      unawaited(_tryCall2(onSettled, null, result));

      state = state.toSuccess(arg: arg, data: result);
      return result;
    } catch (error) {
      ref.dispose();
      if (!mounted) rethrow;

      unawaited(_tryCall1(onError, error));
      unawaited(_tryCall2(onSettled, error, null));

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

  Future<void>? _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
    if (fn == null) return;
    try {
      await fn($1);
    } catch (error, stackTrace) {
      SourceObserver.current.onUncaughtError(this, error, stackTrace);
    }
  }

  Future<void>? _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
    if (fn == null) return;
    try {
      await fn($1, $2);
    } catch (error, stackTrace) {
      SourceObserver.current.onUncaughtError(this, error, stackTrace);
    }
  }
}
