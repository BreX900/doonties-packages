import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension HandleWidgetRef on WidgetRef {
  bool watchIsMutating(Iterable<StateNotifier<MutationState<Object?>>> mutations) {
    return watch(mutations.provider.isMutating);
  }

  VoidCallback? handle<T>(MutationBloc<T, Object?> mutation, T arg) {
    final isMutating = watch(mutation.provider.isMutating);
    if (isMutating) return null;
    return () => mutation(arg);
  }
}

class _GroupListenableProvider<T>
    extends SourceProviderListenable<ISet<StateNotifier<T>>, IList<T>> {
  _GroupListenableProvider(super.source);

  @override
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  IList<T> get state => source.map((e) => e.state).toIList();

  @override
  bool updateShouldNotify(IList<T> prev, IList<T> next) => prev != next;

  @override
  void Function() listen(void Function(IList<T> state) listener) {
    var isInitialized = false;
    final states = <T>[];
    final listenerRemovers = source.mapIndexed((index, source) {
      return source.addListener((state) {
        if (isInitialized) {
          states[index] = state;
          listener(states.toIList());
        } else {
          states.add(state);
        }
      });
    }).toList();
    isInitialized = true;

    return () {
      for (final listenerRemover in listenerRemovers) {
        listenerRemover();
      }
    };
  }
}

extension ProviderGroupStateListenableExtension<T> on Iterable<StateNotifier<T>> {
  ProviderListenable<IList<T>> get provider => _GroupListenableProvider(toISet());
}

extension MutationsGroupProviderListenableExtensions
    on ProviderListenable<Iterable<MutationState>> {
  ProviderListenable<bool> get isMutating => select(_isMutating);

  static bool _isMutating(Iterable<MutationState> states) => states.any((e) => e.isMutating);
}
