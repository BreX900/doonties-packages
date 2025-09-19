// import 'dart:ui';
//
// import 'package:mek/mek.dart';
//
// extension SubscribeWidgetRefExtension on ObserverScope {
//   // void subscribe<T>(
//   //   ProviderListenable<T> provider,
//   //   void Function(T data) listener, {
//   //   bool Function(T? previous, T next)? when,
//   //   void Function(Object error, StackTrace stackTrace)? onError,
//   // }) {
//   //   listen(onError: onError, provider, (previous, next) {
//   //     if (!(when?.call(previous, next) ?? true)) return;
//   //     listener(next);
//   //   });
//   // }
//   //
//   // ProviderSubscription<T> subscribeManual<T>(
//   //   ProviderListenable<T> provider,
//   //   void Function(T data) listener, {
//   //   bool Function(T? previous, T next)? when,
//   //   void Function(Object error, StackTrace stackTrace)? onError,
//   //   bool fireImmediately = false,
//   // }) {
//   //   return listenManual(fireImmediately: true, onError: onError, provider, (previous, next) {
//   //     if (!(when?.call(previous, next) ?? true)) return;
//   //     listener(next);
//   //   });
//   // }
//
//   VoidCallback subscribeManual<T>(
//     Stream<T> stream,
//     void Function(T event) listener, {
//     void Function(Object error, StackTrace stackTrace)? onError,
//   }) {
//     return onDispose(stream.listen(listener, onError: onError).cancel);
//   }
// }
