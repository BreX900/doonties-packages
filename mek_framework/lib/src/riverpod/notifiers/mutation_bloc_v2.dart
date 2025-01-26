// import 'dart:async';
//
// import 'package:flutter/widgets.dart';
// import 'package:mek/mek.dart';
// import 'package:mek/src/core/_log.dart';
//
// mixin NotifiersDisposer on State {
//   final _notifiers = <ChangeNotifier>[];
//
//   MutationNotifier<TArg, TResult> mutation<TArg, TResult>(
//     Future<TResult> Function(MutationReference context, TArg arg) mutator, {
//     StartMutationListener<TArg>? onStart,
//     WillStartMutationListener<TArg>? onWillMutate,
//     ErrorMutationListener<TArg>? onError,
//     DataMutationListener<TArg, TResult>? onData,
//     ResultMutationListener<TArg, TResult>? onFinish,
//   }) {
//     final mutation = MutationNotifier(
//       mutator,
//       onStart: onStart,
//       onWillMutate: onWillMutate,
//       onError: onError,
//       onData: onData,
//       onFinish: onFinish,
//     );
//     _notifiers.add(mutation);
//     return mutation;
//   }
//
//   ChangeNotifier register<T extends ChangeNotifier>(T notifier) {
//     _notifiers.add(notifier);
//     return notifier;
//   }
//
//   @override
//   void dispose() {
//     for (final notifier in _notifiers) {
//       notifier.dispose();
//     }
//     _notifiers.clear();
//     super.dispose();
//   }
// }
//
// mixin DisposableState on NotifiersDisposer {
//   late final mutationV2 = register(MutationNotifier(context, (ref, _) {
//     //sada
//   }, onError: (_, error) {
//     //sada
//   }));
// }
//
// class MutationNotifier<TArg, TResult> extends ValueNotifier<MutationState<TResult>> {
//   final BuildContext context;
//   final Future<TResult> Function(MutationReference ref, TArg arg) _mutator;
//   final StartMutationListener<TArg>? _onStart;
//   final WillStartMutationListener<TArg>? _onWillMutate;
//   final ErrorMutationListener<TArg>? _onError;
//   final DataMutationListener<TArg, TResult>? _onData;
//   final ResultMutationListener<TArg, TResult>? _onFinish;
//
//   MutationNotifier(
//     this.context,
//     this._mutator, {
//     StartMutationListener<TArg>? onStart,
//     WillStartMutationListener<TArg>? onWillMutate,
//     ErrorMutationListener<TArg>? onError,
//     DataMutationListener<TArg, TResult>? onData,
//     ResultMutationListener<TArg, TResult>? onFinish,
//   })  : _onStart = onStart,
//         _onWillMutate = onWillMutate,
//         _onError = onError,
//         _onData = onData,
//         _onFinish = onFinish,
//         super(IdleMutation<TResult>());
//
//   // ignore: discarded_futures
//   void call(TArg arg) => run(arg);
//
//   Future<void> run(TArg arg) async {
//     if (_isDisposed) throw StateError("Can't mutate if bloc is closed!");
//
//     if (value.args.contains(arg)) {
//       lg.info('Bloc is mutating! $this');
//       return;
//     }
//
//     if (!(await _onWillMutate?.call(arg) ?? true)) return;
//
//     value = value.toLoading(arg: arg);
//
//     await _tryCall1(_onStart, arg);
//
//     final ref = MutationReference._(this);
//     try {
//       final result = await _mutator(ref, arg);
//       ref._dispose();
//
//       if (_isDisposed) {
//         lg.info('Bloc is closed! Cant emit success state. $this');
//         return;
//       }
//
//       await _tryCall2(_onData, arg, result);
//       await _tryCall3(_onFinish, arg, null, result);
//
//       value = value.toSuccess(arg: arg, data: result);
//     } catch (error, stackTrace) {
//       addError(error, stackTrace);
//       ref._dispose();
//
//       if (_isDisposed) {
//         lg.info('Bloc is closed!  Cant emit failed state. $this');
//         return;
//       }
//
//       await _tryCall2(_onError, arg, error);
//       await _tryCall3(_onFinish, arg, error, null);
//
//       value = value.toFailed(arg: arg, error: error);
//
//       rethrow;
//     }
//   }
//
//   void updateProgress(double progress) {
//     if (value is! LoadingMutation<TResult>) {
//       lg.info("Bloc isn't mutating! Cant update progress state. $this");
//       return;
//     }
//     value = value.toLoading(arg: value.args.single, progress: progress);
//   }
//
//   bool _isDisposed = false;
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     super.dispose();
//   }
//
//   FutureOr<void> _tryCall1<T1>(FutureOr<void> Function(T1)? fn, T1 $1) async {
//     if (fn == null) return;
//     try {
//       await fn($1);
//     } catch (error, stackTrace) {
//       addError(error, stackTrace);
//     }
//   }
//
//   FutureOr<void> _tryCall2<T1, T2>(FutureOr<void> Function(T1, T2)? fn, T1 $1, T2 $2) async {
//     if (fn == null) return;
//     try {
//       await fn($1, $2);
//     } catch (error, stackTrace) {
//       addError(error, stackTrace);
//     }
//   }
//
//   FutureOr<void> _tryCall3<T1, T2, T3>(
//     FutureOr<void> Function(T1, T2, T3)? fn,
//     T1 $1,
//     T2 $2,
//     T3 $3,
//   ) async {
//     if (fn == null) return;
//     try {
//       await fn($1, $2, $3);
//     } catch (error, stackTrace) {
//       addError(error, stackTrace);
//     }
//   }
// }
//
// class MutationReference {
//   MutationNotifier? _notifier;
//
//   MutationReference._(this._notifier);
//
//   void updateProgress(double progress) {
//     _notifier!.updateProgress(progress);
//   }
//
//   void _dispose() {
//     _notifier = null;
//   }
// }
