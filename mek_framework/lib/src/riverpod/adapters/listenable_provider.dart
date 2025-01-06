import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension ListenableProviderExtension on TabController {
  ProviderListenable<TabController> get provider => _ListenableProvider(this);
}

extension TabControllerProviderExtension on ProviderListenable<TabController> {
  ProviderListenable<int> get index => select(_index);

  static int _index(TabController controller) => controller.index;
}

class _ListenableProvider<T extends Listenable> extends SourceProviderListenable<T, T> {
  const _ListenableProvider(super.source);

  @override
  T get state => source;

  @override
  void Function() listen(void Function(T state) listener) {
    void onChange() => listener(source);
    source.addListener(onChange);
    return () => source.removeListener(onChange);
  }
}
