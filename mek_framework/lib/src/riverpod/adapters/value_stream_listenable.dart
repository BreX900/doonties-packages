// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
// import 'package:mekart/mekart.dart';
// import 'package:rxdart/rxdart.dart';
//
// extension ValueStreamProviderExtension<T> on ValueStream<T> {
//   ProviderListenable<T> get provider => _ValueStreamProvider(this);
//
//   ProviderListenable<R> select<R>(R Function(T value) selector) => provider.select(selector);
// }
//
// class _ValueStreamProvider<T> extends SourceProviderListenable<ValueStream<T>, T> {
//   _ValueStreamProvider(super.source);
//
//   @override
//   T get state => source.value;
//
//   @override
//   bool updateShouldNotify(T prev, T next) => !iEquality.equals(prev, next);
//
//   @override
//   void Function() listen(void Function(T state) listener) => source.listen(listener).cancel;
// }
