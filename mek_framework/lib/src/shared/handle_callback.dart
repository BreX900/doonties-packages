// import 'dart:ui';
//
// import 'package:collection/collection.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mek/src/riverpod/notifiers/mutation_bloc.dart';
// import 'package:mek/src/riverpod/notifiers/mutation_state.dart'; // ignore: implementation_imports
// import 'package:rivertion/src/internals.dart';
//
// extension HandleWidgetRef on WidgetRef {
//   bool watchIsMutating(Iterable<ValueListenable<MutationState<Object?>>> mutations) {
//     for (final mutation in mutations) {
//       if (watch(mutation.provider))
//     }
//     return watchSource(mutations.map((e) => e.source).source.isMutating);
//   }
//
//   VoidCallback? handle<T>(MutationBloc<T, Object?> mutation, T arg) {
//     final isMutating = watchSource(mutation.source.isMutating);
//     if (isMutating) return null;
//     return () => mutation(arg);
//   }
// }
//
// extension ProviderGroupStateListenableExtension<T> on Iterable<Source<T>> {
//   SourceListenable<List<T>> get source => _GroupSource(this);
// }
//
// extension MutationsGroupProviderListenableExtensions on SourceListenable<Iterable<MutationState>> {
//   SourceListenable<bool> get isMutating => select(_isMutating);
//
//   static bool _isMutating(Iterable<MutationState> states) => states.any((e) => e.isMutating);
// }
//
// final class _GroupSource<T> extends SourceListenable<List<T>> with EquatableMixin {
//   final Iterable<Source<T>> sources;
//
//   _GroupSource(this.sources);
//
//   @override
//   SourceSubscription<List<T>> listen(SourceListener<List<T>> listener) {
//     late List<T> current;
//     final subscriptions = sources.mapIndexed((index, source) {
//       return source.listenable.listen((previousState, state) {
//         final previous = current;
//         current = [...current]..[index] = state;
//         if (previous.equals(current)) return;
//         listener(previous, current);
//       });
//     }).toList();
//     current = subscriptions.map((e) => e.read()).toList();
//
//     return SourceSubscription.viaAdapter((previous, current) {}, (context) {
//       context.state = current;
//       return () {
//         for (final subscription in subscriptions) {
//           subscription.cancel();
//         }
//       };
//     });
//   }
//
//   @override
//   List<Object?> get props => [sources];
// }
