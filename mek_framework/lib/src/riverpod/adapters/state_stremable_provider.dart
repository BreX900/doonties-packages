import 'package:bloc/bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';

extension StateStreamableProviderExtension<T> on StateStreamable<T> {
  ProviderListenable<T> get provider => _StateStreamableProvider(this);

  ProviderListenable<R> select<R>(R Function(T value) selector) => provider.select(selector);
}

class _StateStreamableProvider<T> extends SourceProviderListenable<StateStreamable<T>, T> {
  _StateStreamableProvider(super.source);

  @override
  T get state => source.state;

  @override
  void Function() listen(void Function(T state) listener) => source.stream.listen(listener).cancel;
}
