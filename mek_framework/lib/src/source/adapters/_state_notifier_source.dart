part of '../source.dart';

extension SourceStateNotifierExtension<T> on StateNotifier<T> {
  Source<T> get source => _StateNotifierSource(this);
}

class _StateNotifierSource<T> extends Source<T> with EquatableMixin {
  final StateNotifier<T> notifier;

  _StateNotifierSource(this.notifier);

  @override
  SourceSubscription<T> listen(SourceListener<T> listener) {
    _Optional<T>? current;
    final listenerRemover = notifier.addListener((state) {
      if (current case final previous?) {
        current = _Optional(state);
        Zone.current.runBinaryGuarded(listener, previous.value, state);
      } else {
        current = _Optional(state);
      }
    });
    return _StateNotifierSourceSubscription(listenerRemover, () => current!.value);
  }

  @override
  List<Object?> get props => [notifier];
}

final class _StateNotifierSourceSubscription<T extends Listenable, R>
    extends SourceSubscription<R> {
  final void Function() listenerRemover;
  final ValueGetter<R> reader;

  _StateNotifierSourceSubscription(this.listenerRemover, this.reader);

  @override
  R read() {
    assert(SourceSubscription.debugIsCancelled(this));
    return reader();
  }

  @override
  void cancel() {
    listenerRemover();
    super.cancel();
  }
}

// class _Optional<T> {
//   final T value;
//
//   const _Optional(this.value);
// }
