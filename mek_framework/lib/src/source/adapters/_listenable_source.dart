part of '../source.dart';

extension SourceListenableExtension<T extends Listenable> on T {
  Source<R> sourceBy<R>(R Function(T listenable) selector) => _ListenableSource(this, selector);
}

extension SourceValueListenableExtension<T> on ValueListenable<T> {
  Source<T> get source => _ListenableSource(this, _selectValue);

  static T _selectValue<T>(ValueListenable<T> listenable) => listenable.value;
}

class _ListenableSource<T extends Listenable, R> extends Source<R> with EquatableMixin {
  final T listenable;
  final R Function(T listenable) selector;

  _ListenableSource(this.listenable, this.selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = selector(listenable);
    void onChange() {
      final previous = current;
      current = selector(listenable);
      if (previous == current) return;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    listenable.addListener(onChange);
    return _ListenableSubscription(listenable, onChange, () => current);
  }

  @override
  List<Object?> get props => [listenable, selector];
}

final class _ListenableSubscription<T extends Listenable, R> extends SourceSubscription<R> {
  final T listenable;
  final VoidCallback listener;
  final ValueGetter<R> reader;

  _ListenableSubscription(this.listenable, this.listener, this.reader);

  @override
  R read() {
    assert(SourceSubscription.debugIsCancelled(this));
    return reader();
  }

  @override
  void cancel() {
    listenable.removeListener(listener);
    super.cancel();
  }
}
