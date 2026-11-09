import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/notifiers/notifier_mount.dart';
import 'package:mek/src/notifiers/notifier_observer.dart';
import 'package:mek/src/riverpod/notifiers/_mutation.dart';
import 'package:mekart/mekart.dart';

typedef ErrorMutationListenerV2 = FutureOr<void> Function(Object error, StackTrace stackTrace);
typedef DataMutationListenerV2<Result> = FutureOr<void> Function(Result result);
typedef ResultMutationListenerV2<Result> = FutureOr<void> Function(Object? error, Result? result);

class MutationController<T> extends ValueNotifier<MutationState<T>>
    with NotifierMount
    implements MutationDelegate<void> {
  final ValueNotifier<int>? _parent;
  final ProviderContainer Function() _containerReader;

  MutationController(WidgetRef ref, [this._parent])
    : _containerReader = (() => ref.container),
      super(MutationIdle<T>());

  MutationController.internal(this._containerReader, [this._parent]) : super(MutationIdle<T>());

  void call<R extends T>(
    Future<R> Function(MutationRef ref) mutator, {
    required ErrorMutationListenerV2? onError,
    DataMutationListenerV2<R>? onSuccess,
    ResultMutationListenerV2<R>? onSettled,
  }) {
    _ensureCanMutate();

    final originStackTrace = StackTrace.current;
    Future<void>.sync(() async {
      try {
        await _run<R>(mutator, onError: onError, onSuccess: onSuccess, onSettled: onSettled);
      } catch (error, stackTrace) {
        if (!mounted) return;
        NotifierObserver.current.onUncaughtError(this, error, stackTrace.combine(originStackTrace));
      }
    }).unawaited;
  }

  Future<bool?> execute<R extends T>(
    Future<R> Function(MutationRef ref) mutator, {
    required ErrorMutationListenerV2? onError,
    DataMutationListenerV2<R>? onSuccess,
    ResultMutationListenerV2<R>? onSettled,
  }) {
    _ensureCanMutate();

    final originStackTrace = StackTrace.current;
    return Future.sync(() async {
      try {
        await _run<R>(mutator, onError: onError, onSuccess: onSuccess, onSettled: onSettled);
        if (!mounted) return null;
        return true;
      } catch (error, stackTrace) {
        if (!mounted) return null;
        NotifierObserver.current.onUncaughtError(this, error, stackTrace.combine(originStackTrace));
        return false;
      }
    });
  }

  void _ensureCanMutate() {
    if (!mounted) throw StateError("Can't mutate if is closed!");
    if (value.isPending) throw StateError("Can't mutate if is mutating!");
  }

  Future<R> _run<R extends T>(
    Future<R> Function(MutationRef ref) mutator, {
    required ErrorMutationListenerV2? onError,
    DataMutationListenerV2<R>? onSuccess,
    ResultMutationListenerV2<R>? onSettled,
  }) async {
    value = value.toLoading(arg: null);
    _parent?.value += 1;

    final ref = MutationRefImpl(_containerReader(), this, null);
    try {
      final result = await mutator(ref);
      ref.dispose();
      if (!mounted) return result;

      unawaited(_tryCall1(onSuccess, result));
      unawaited(_tryCall2(onSettled, null, result));

      value = value.toSuccess(arg: null, data: result);
      return result;
    } catch (error, stackTrace) {
      ref.dispose();
      if (!mounted) rethrow;

      unawaited(_tryCall2(onError, error, stackTrace));
      unawaited(_tryCall2(onSettled, error, null));

      value = value.toFailed(arg: null, error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _parent?.value -= 1;
    }
  }

  @override
  void updateProgress(void arg, double value) {
    if (this.value is! MutationPending<T>) {
      lg.info("Bloc isn't mutating! Cant update progress state. $this");
      return;
    }
    this.value = this.value.toLoading(arg: null, progress: value);
  }

  Future<void>? _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
    if (fn == null) return;
    try {
      await fn($1);
    } catch (error, stackTrace) {
      NotifierObserver.current.onUncaughtError(this, error, stackTrace);
    }
  }

  Future<void>? _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
    if (fn == null) return;
    try {
      await fn($1, $2);
    } catch (error, stackTrace) {
      NotifierObserver.current.onUncaughtError(this, error, stackTrace);
    }
  }
}

final class CombinedStackTrace._(final StackTrace top, final StackTrace bottom)
    implements StackTrace {
  @override
  String toString() => '$top\n$bottom';
}

extension CombineStackTraceExtension on StackTrace {
  StackTrace combine(StackTrace bottom) {
    if (bottom == .empty) return this;
    if (this == .empty) return bottom;
    return CombinedStackTrace._(this, bottom);
  }
}
