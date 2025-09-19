// import 'package:flutter/foundation.dart';
// // ignore: implementation_imports
// import 'package:flutter_riverpod/src/internals.dart';
//
// extension AutoDisposeWidgetRefExtension on WidgetRef {
//   ProviderSubscription<void> onDispose<T>(VoidCallback disposer) {
//     return listenManual(_AutoDisposeProviderListenable(disposer), _noop);
//   }
//
//   ProviderSubscription<void> listenManualStream<T>(
//     Stream<T> stream,
//     void Function(T? prev, T next) listener, {
//     void Function(Object error, StackTrace stackTrace)? onError,
//   }) {
//     T? prev;
//     return onDispose(stream.listen((next) {
//       listener(prev, next);
//       prev = next;
//     }, onError: onError).cancel);
//   }
//
//   static void _noop(_, __) {}
// }
//
// class _AutoDisposeProviderListenable implements ProviderListenable<void> {
//   final VoidCallback disposer;
//
//   _AutoDisposeProviderListenable(this.disposer);
//
//   @override
//   ProviderSubscription<void> addListener(
//     Node node,
//     void Function(void previous, void next) listener, {
//     required void Function(Object error, StackTrace stackTrace)? onError,
//     required void Function()? onDependencyMayHaveChanged,
//     required bool fireImmediately,
//   }) {
//     return _AutoDisposeProviderSubscription(node, disposer);
//   }
//
//   @override
//   void read(Node node) {}
//
//   @override
//   ProviderListenable<Selected> select<Selected>(Selected Function(void value) selector) =>
//       throw UnimplementedError();
// }
//
// class _AutoDisposeProviderSubscription extends ProviderSubscription<void> {
//   final VoidCallback disposer;
//
//   _AutoDisposeProviderSubscription(super.source, this.disposer);
//
//   @override
//   void close() {
//     super.close();
//     disposer();
//   }
//
//   @override
//   void read() {}
// }
