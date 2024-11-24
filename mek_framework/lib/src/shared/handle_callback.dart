import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/data/mutation_state.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension HandleWidgetRef on WidgetRef {
  static bool shouldFormValid = true;

  bool watchIsMutating(Iterable<StateListenable<MutationState<Object?>>> mutations) {
    return watch(mutations.provider.isMutating);
  }
}

class _GroupListenableProvider<T>
    extends SourceProviderListenable<ISet<StateListenable<T>>, IList<T>> {
  _GroupListenableProvider(super.source);

  @override
  IList<T> get state => source.map((e) => e.state).toIList();

  @override
  bool updateShouldNotify(IList<T> prev, IList<T> next) => prev != next;

  @override
  void Function() listen(void Function(IList<T> state) listener) {
    final listenerRemovers = source.map((source) {
      return source.addListener((_) => listener(state));
    }).toList();

    return () {
      for (final listenerRemover in listenerRemovers) {
        listenerRemover();
      }
    };
  }
}

extension ProviderGroupStateListenableExtension<T> on Iterable<StateListenable<T>> {
  ProviderListenable<IList<T>> get provider => _GroupListenableProvider(toISet());
}

extension MutationsGroupProviderListenableExtensions
    on ProviderListenable<Iterable<MutationState>> {
  ProviderListenable<bool> get isMutating => select(_isMutating);

  static bool _isMutating(Iterable<MutationState> states) => states.any((e) => e.isMutating);
}
