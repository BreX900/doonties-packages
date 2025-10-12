import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:mek/mek.dart';

extension HandleWidgetRef on ConsumerScope {
  bool watchIsMutating(Iterable<SourceNotifier<MutationState<Object?>>> mutations) {
    return watch(mutations.map((e) => e.source).source.isMutating);
  }

  VoidCallback? handle<T>(MutationBloc<T, Object?> mutation, T arg) {
    final isMutating = watch(mutation.source.isMutating);
    if (isMutating) return null;
    return () => mutation(arg);
  }
}

extension ProviderGroupStateListenableExtension<T> on Iterable<Source<T>> {
  Source<List<T>> get source => _GroupSource(this);
}

extension MutationsGroupProviderListenableExtensions on Source<Iterable<MutationState>> {
  Source<bool> get isMutating => select(_isMutating);

  static bool _isMutating(Iterable<MutationState> states) => states.any((e) => e.isMutating);
}

class _GroupSource<T> extends Source<List<T>> with EquatableMixin {
  final Iterable<Source<T>> sources;

  _GroupSource(this.sources);

  @override
  SourceSubscription<List<T>> listen(SourceListener<List<T>> listener) {
    late List<T> current;
    final subscriptions = sources.mapIndexed((index, source) {
      return source.listen((previousState, state) {
        final previous = current;
        current = [...current]..[index] = state;
        if (previous.equals(current)) return;
        listener(previous, current);
      });
    }).toList();
    current = subscriptions.map((e) => e.read()).toList();

    return _GroupSubscription(subscriptions, () => current);
  }

  @override
  List<Object?> get props => [sources];
}

base class _GroupSubscription<T> extends SourceSubscription<List<T>> {
  final List<SourceSubscription<T>> subscriptions;
  final List<T> Function() reader;

  _GroupSubscription(this.subscriptions, this.reader);

  @override
  List<T> read() {
    SourceSubscription.debugIsCancelled(this);
    return reader();
  }

  @override
  void cancel() {
    super.cancel();
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
  }
}
