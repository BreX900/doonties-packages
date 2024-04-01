import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart';

extension AutoDisposeWidgetRefExtension on WidgetRef {
  void autoDispose<T>(VoidCallback disposer) {
    listenManual(_AutoDisposeProviderListenable(disposer), _noop);
  }

  static void _noop(_, __) {}
}

class _AutoDisposeProviderListenable with ProviderListenable<void> {
  final VoidCallback disposer;

  _AutoDisposeProviderListenable(this.disposer);

  @override
  ProviderSubscription<void> addListener(
    Node node,
    void Function(void previous, void next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    return _AutoDisposeProviderSubscription(node, disposer);
  }

  @override
  void read(Node node) {}
}

class _AutoDisposeProviderSubscription extends ProviderSubscription<void> {
  final VoidCallback disposer;

  _AutoDisposeProviderSubscription(super.source, this.disposer);

  @override
  void close() {
    disposer();
    super.close();
  }

  @override
  void read() {}
}
