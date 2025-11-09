part of '../source.dart';

extension SelectSourceExtension<T> on Source<T> {
  Source<R> select<R>(R Function(T state) selector) => _SourceSelector(this, selector);

  Source<R> selectWith<R, A>(A arg, R Function(A arg, T state) selector) =>
      _SourceArgSelector(this, arg, selector);
}

class _SourceSelector<T, R> extends _SourceTransformer<T, R> {
  final R Function(T state) selector;

  _SourceSelector(super.source, this.selector);

  @override
  R select(T state) => selector(state);

  @override
  List<Object?> get props => [source, selector];
}

// ignore: must_be_immutable
class _SourceArgSelector<T, R, A> extends _SourceTransformer<T, R> {
  final A arg;
  final R Function(A arg, T value) selector;

  _SourceArgSelector(super.source, this.arg, this.selector);

  @override
  R select(T state) => selector(arg, state);

  @override
  List<Object?> get props => [source, arg, selector];
}

abstract class _SourceTransformer<T, R> extends Source<R> with EquatableMixin {
  final Source<T> source;

  _SourceTransformer(this.source);

  R select(T state);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    _Optional<R>? current;
    final subscription = source.listen((previousState, currentState) {
      final previous = current ?? _Optional(select(previousState));
      final next = _Optional(select(currentState));
      current = next;
      if (previous.value == next.value) return;
      Zone.current.runBinaryGuarded(listener, previous.value, next.value);
    });
    return _SourceTransformerSubscription(subscription, () {
      return (current ??= _Optional(select(subscription.read()))).value;
    });
  }
}

final class _SourceTransformerSubscription<T, R> extends SourceSubscription<R> {
  final SourceSubscription<T> subscription;
  final R Function() reader;

  _SourceTransformerSubscription(this.subscription, this.reader);

  @override
  R read() {
    assert(SourceSubscription.debugIsCancelled(this));
    return reader();
  }

  @override
  void cancel() {
    subscription.cancel();
    super.cancel();
  }
}
