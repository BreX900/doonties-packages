import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/riverpod/notifiers/_mutation.dart';

typedef ErrorMutationListenerV2 = FutureOr<void> Function(Object error);
typedef DataMutationListenerV2<Result> = FutureOr<void> Function(Result result);
typedef ResultMutationListenerV2<Result> = FutureOr<void> Function(Object? error, Result? result);

class MutationNotifier<TArg, TResult> extends StateNotifier<MutationState<TResult>>
    implements Mutation<TArg> {
  final ProviderContainer Function() _readContainer;
  final Future<TResult> Function(MutationRef ref, TArg arg) _mutator;

  MutationNotifier(this._readContainer, this._mutator) : super(IdleMutation<TResult>());

  void call(
    TArg arg, {
    ErrorMutationListenerV2? onError,
    DataMutationListenerV2<TResult>? onData,
    ResultMutationListenerV2<TResult>? onSettled,
  }) {
    // ignore: discarded_futures
    run(arg, onError: onError, onData: onData, onSettled: onSettled).ignore();
  }

  Future<void> run(
    TArg arg, {
    ErrorMutationListenerV2? onError,
    DataMutationListenerV2<TResult>? onData,
    ResultMutationListenerV2<TResult>? onSettled,
  }) async {
    if (!mounted) throw StateError("Can't mutate if bloc is closed!");

    state = state.toLoading(arg: arg);

    final ref = MutationRefImpl(_readContainer(), this, arg);
    try {
      final result = await _mutator(ref, arg);
      ref.dispose();
      if (!mounted) return;

      await _tryCall1(onData, result);
      if (!mounted) return;

      await _tryCall2(onSettled, null, result);
      if (!mounted) return;

      state = state.toSuccess(arg: arg, data: result);
    } catch (error, stackTrace) {
      // addError(error, stackTrace);
      ref.dispose();
      if (!mounted) return;

      await _tryCall1(onError, error);
      if (!mounted) return;

      await _tryCall2(onSettled, error, null);
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
    emit(state.toLoading(arg: arg, progress: value));
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
}
