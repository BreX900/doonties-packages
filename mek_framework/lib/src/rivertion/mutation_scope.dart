// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/misc.dart';
// import 'package:mek/src/riverpod/notifiers/mutation_controller.dart';
// import 'package:mek/src/riverpod/notifiers/mutation_ref.dart';
// import 'package:mek/src/riverpod/notifiers/mutation_state.dart';
// import 'package:rivertion/rivertion.dart';
//
// sealed class MutationTarget<T> {
//   MutationController<T> _create(ProviderContainer container, void Function() onDisposed) =>
//       MutationController.internal(() => container);
//
//   void mutate(
//     BuildContext context,
//     Future<T> Function(MutationRef ref) body, {
//     required ErrorMutationListenerV2? onError,
//     DataMutationListenerV2<T>? onSuccess,
//     ResultMutationListenerV2<T>? onSettled,
//   }) => MutationScope._of(
//     context,
//     this,
//   ).call(body, onError: onError, onSuccess: onSuccess, onSettled: onSettled);
// }
//
// class Mutation<T> extends MutationTarget<T> {
//   static void Function(Object error, StackTrace stackTrace) onError = _onError;
//
//   final String label;
//
//   Mutation(this.label);
//
//   MutationTarget<T> call(Object? arg) {
//     if (arg == null) return this;
//     return _MutationFamily._(this, arg);
//   }
//
//   static void _onError(Object error, StackTrace stackTrace) {
//     Zone.current.handleUncaughtError(error, stackTrace);
//   }
//
//   @override
//   String toString() => 'Mutation#$label';
// }
//
// @immutable
// final class _MutationFamily<T> extends MutationTarget<T> {
//   final Mutation<T> _origin;
//   final Object? _arg;
//
//   _MutationFamily._(this._origin, this._arg);
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is _MutationFamily &&
//           runtimeType == other.runtimeType &&
//           _origin == other._origin &&
//           _arg == other._arg;
//
//   @override
//   int get hashCode => Object.hash(_origin, _arg);
//
//   @override
//   String toString() => '$_origin($_arg)';
// }
//
// extension MutationBuildContextExtensions on BuildContext {
//   ProviderListenable<MutationState<R>> mutation<R>(MutationTarget<R> target) =>
//       MutationScope._of<R>(this, target).provider;
// }
//
// class MutationScope extends StatefulWidget {
//   final Widget child;
//
//   const MutationScope({super.key, required this.child});
//
//   static MutationController<R> _of<R>(BuildContext context, MutationTarget<R> target) {
//     final model = context.dependOnInheritedWidgetOfExactType<_UncontrolledMutationScope>(
//       aspect: target,
//     )!;
//     return model.state.readController<R>(target);
//   }
//
//   @override
//   State<MutationScope> createState() => _MutationScopeState();
// }
//
// class _MutationScopeState extends State<MutationScope> {
//   late Map<MutationTarget<Object?>, _Box> _pointers;
//
//   @override
//   void initState() {
//     super.initState();
//     _pointers = {};
//   }
//
//   @override
//   void dispose() {
//     for (final pointer in _pointers.values) {
//       pointer.notifier.dispose();
//     }
//     _pointers = const {};
//     super.dispose();
//   }
//
//   MutationController<R> readController<R>(MutationTarget<R> target) {
//     final controller = _pointers[target]?.notifier;
//     assert(controller != null, 'You need depend to MutationScope before access to controller!');
//     return controller! as MutationController<R>;
//   }
//
//   void createDependency(MutationTarget<Object?> target, Element dependent) {
//     final pointer = _pointers.putIfAbsent(target, () {
//       return _Box(
//         target._create(ProviderScope.containerOf(context, listen: false), () {
//           _pointers.remove(target);
//         }),
//         {},
//       );
//     });
//     pointer.dependents.add(dependent);
//   }
//
//   void removeDependency(MutationTarget<Object?> target, Element dependent) {
//     final pointer = _pointers[target];
//     if (pointer == null) return;
//
//     pointer.dependents.remove(dependent);
//   }
//
//   @override
//   Widget build(BuildContext context) =>
//       _UncontrolledMutationScope(state: this, child: widget.child);
// }
//
// class _UncontrolledMutationScope extends InheritedWidget {
//   final _MutationScopeState state;
//
//   const _UncontrolledMutationScope({required this.state, required super.child});
//
//   @override
//   bool updateShouldNotify(_UncontrolledMutationScope oldWidget) => state != oldWidget.state;
//
//   @override
//   InheritedElement createElement() => _MutationScopeElement(this);
// }
//
// class _MutationScopeElement extends InheritedElement {
//   _MutationScopeElement(_UncontrolledMutationScope super.widget);
//
//   _MutationScopeState get _state => (widget as _UncontrolledMutationScope).state;
//
//   @override
//   void updateDependencies(Element dependent, covariant MutationTarget<Object?> aspect) {
//     final targets = getDependencies(dependent) as Set<MutationTarget>?;
//     setDependencies(dependent, <MutationTarget<Object?>>{...?targets, aspect});
//
//     _state.createDependency(aspect, dependent);
//   }
//
//   @override
//   void removeDependent(Element dependent) {
//     if (getDependencies(dependent) case final Set<MutationTarget<Object?>> targets) {
//       for (final target in targets) {
//         _state.removeDependency(target, dependent);
//       }
//     }
//
//     super.removeDependent(dependent);
//   }
// }
//
// class _Box {
//   final MutationController<Object?> notifier;
//   final Set<Element> dependents;
//
//   _Box(this.notifier, this.dependents);
// }
