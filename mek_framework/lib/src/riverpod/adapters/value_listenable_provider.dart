import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension ValueListenableProviderExtension<T> on ValueListenable<T> {
  ProviderListenable<T> get provider => _ValueListenableProvider(this);

  ProviderListenable<R> select<R>(R Function(T value) selector) => provider.select(selector);
}

class _ValueListenableProvider<T> extends SourceProviderListenable<ValueListenable<T>, T> {
  _ValueListenableProvider(super.source);

  @override
  T get state => source.value;

  @override
  void Function() listen(void Function(T state) listener) {
    void onChange() => listener(source.value);
    source.addListener(onChange);
    return () => source.removeListener(onChange);
  }
}
