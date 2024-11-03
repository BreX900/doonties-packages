import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension ListenableProviderExtension<T extends ChangeNotifier> on T {
  ProviderListenable<R> pick<R>(R Function(T listenable) selector) =>
      _ListenableProvider(this, selector);
}

class _ListenableProvider<T extends Listenable, R> extends SourceProviderListenable<T, R> {
  final R Function(T listenable) selector;

  _ListenableProvider(super.source, this.selector);

  @override
  R get state => selector(source);

  @override
  void Function() listen(void Function(R state) listener) {
    void onChange() => listener(selector(source));
    source.addListener(onChange);
    return () => source.removeListener(onChange);
  }
}
