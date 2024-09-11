import 'dart:async';

import 'package:equatable/equatable.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:riverpod/src/framework.dart';

class _DebounceProvider<T> with ProviderListenable<T>, EquatableMixin {
  final ProviderListenable<T> provider;
  final Duration time;

  _DebounceProvider(this.provider, this.time);

  @override
  ProviderSubscription<T> addListener(
    Node node,
    void Function(T? previous, T next) listener, {
    required void Function(Object error, StackTrace stackTrace)? onError,
    required void Function()? onDependencyMayHaveChanged,
    required bool fireImmediately,
  }) {
    if (fireImmediately) listener(null, provider.read(node));

    Timer? timer;
    return provider.addListener(
      node,
      (previous, next) {
        timer?.cancel();
        timer = Timer(time, () {
          listener(previous, next);
          timer = null;
        });
      },
      onError: onError,
      onDependencyMayHaveChanged: onDependencyMayHaveChanged,
      fireImmediately: fireImmediately,
    );
  }

  @override
  T read(Node node) => provider.read(node);

  @override
  List<Object?> get props => [provider, time];
}

extension DebounceProviderListenableExtension<T> on ProviderListenable<T> {
  ProviderListenable<T> debounce(Duration time) => _DebounceProvider(this, time);
}
