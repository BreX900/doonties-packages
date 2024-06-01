import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension StateNotifierProviderExtension<T> on StateNotifier<T> {
  ProviderListenable<T> get provider => _StateNotifierProvider(this);

  ProviderListenable<R> select<R>(R Function(T value) selector) => provider.select(selector);
}

class _StateNotifierProvider<T> extends SourceProviderListenable<StateNotifier<T>, T> {
  _StateNotifierProvider(super.source);

  @override
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  T get state => source.state;

  @override
  void Function() listen(void Function(T state) listener) => source.addListener(listener);
}
