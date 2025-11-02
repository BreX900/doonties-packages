part of 'source.dart';

typedef SourceScope = WidgetScope;

final class WidgetScope {
  final _SourceStatefulElementMixin _element;

  BuildContext get context => _element;

  WidgetScope._(this._element);

  void listen<T>(Source<T> source, SourceListener<T> listener) {
    _assertNotDisposed();
    _element._listen(source, listener);
  }

  T watch<T>(Source<T> source) {
    _assertNotDisposed();
    return _element._watch(source);
  }

  void listenManual<T>(
    Source<T> source,
    void Function(T? previous, T state) listener, {
    bool fireImmediately = false,
  }) {
    _assertNotDisposed();
    _element._listenManual(source, listener, fireImmediately: fireImmediately);
  }

  void subscribe<T>(Stream<T> stream, void Function(T event) listener) {
    _assertNotDisposed();
    _element._subscribe(stream, listener);
  }

  VoidCallback subscribeManual<T>(Stream<T> stream, void Function(T event) listener) {
    _assertNotDisposed();
    return _element._subscribeManual(stream, listener);
  }

  VoidCallback onDispose(VoidCallback onDispose) {
    _assertNotDisposed();
    return _element._onDispose(onDispose);
  }

  void _assertNotDisposed() {
    if (_element.mounted) return;
    throw StateError('Cannot use "scope" after the widget was disposed.');
  }
}

class SourceBuilder extends SourceWidget {
  final Widget Function(BuildContext context, WidgetScope scope, Widget? child) builder;

  const SourceBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetScope scope) => builder(context, scope, null);
}

abstract class SourceWidget extends SourceStatefulWidget {
  const SourceWidget({super.key});

  Widget build(BuildContext context, WidgetScope scope);

  @override
  SourceState<SourceStatefulWidget> createState() => _SourceState();
}

class _SourceState extends SourceState<SourceWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, scope);
}

abstract class SourceStatefulWidget extends StatefulWidget {
  const SourceStatefulWidget({super.key});

  @override
  SourceState<SourceStatefulWidget> createState();

  @override
  StatefulElement createElement() => _SourceStatefulElement(this);
}

abstract class SourceState<T extends SourceStatefulWidget> extends State<T> {
  late final WidgetScope scope = WidgetScope._(context as _SourceStatefulElement);
}

class _SourceStatefulElement extends StatefulElement with _SourceStatefulElementMixin {
  _SourceStatefulElement(SourceStatefulWidget super.widget);
}

mixin _SourceStatefulElementMixin on StatefulElement {
  final _listenerRemovers = <VoidCallback>[];
  var _dependencies = <Source<Object?>, SourceSubscription<Object?>>{};
  var _oldDependencies = <Source<Object?>, SourceSubscription<Object?>>{};
  final _onDisposeListeners = <VoidCallback>[];

  @override
  void unmount() {
    super.unmount();

    for (final listenerRemover in _listenerRemovers) {
      listenerRemover();
    }
    _listenerRemovers.clear();
    for (final subscription in _dependencies.values) {
      subscription.cancel();
    }
    _dependencies = const {};
    for (final disposer in _onDisposeListeners) {
      disposer();
    }
  }

  void _listen<T>(Source<T> source, SourceListener<T> listener) =>
      _listenerRemovers.add(source.listen(listener).cancel);

  T _watch<T>(Source<T> source) {
    final subscription = _dependencies.putIfAbsent(source, () {
      return source.listen(_listenerForRebuild);
    });
    return subscription.read() as T;
  }

  void _listenManual<T>(
    Source<T> source,
    void Function(T? previous, T state) listener, {
    required bool fireImmediately,
  }) {
    final subscription = source.listen(listener);
    _onDisposeListeners.add(subscription.cancel);
    if (fireImmediately) Zone.current.runBinaryGuarded(listener, null, subscription.read());
  }

  void _subscribe<T>(Stream<T> stream, void Function(T event) listener) {
    _listenerRemovers.add(stream.listen(listener).cancel);
  }

  VoidCallback _subscribeManual<T>(Stream<T> stream, void Function(T event) listener) {
    final disposer = stream.listen(listener).cancel;
    _onDisposeListeners.add(disposer);
    return disposer;
  }

  VoidCallback _onDispose(VoidCallback onDispose) {
    _onDisposeListeners.add(onDispose);
    return () => _onDisposeListeners.remove(onDispose);
  }

  void _listenerForRebuild(_, __) => markNeedsBuild();

  @override
  Widget build() {
    try {
      _oldDependencies = _dependencies;
      for (final listenerRemover in _listenerRemovers) {
        listenerRemover();
      }
      _listenerRemovers.clear();
      _dependencies = {};
      return super.build();
    } finally {
      for (final subscription in _oldDependencies.values) {
        subscription.cancel();
      }
      _oldDependencies = const {};
    }
  }
}
