// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
//
// extension ListenableProviderExtension on TabController {
//   ProviderListenable<TabController> get provider => _ListenableProvider(this);
// }
//
// extension TabControllerProvidersExtensions on ProviderListenable<TabController> {
//   ProviderListenable<int> get index => select(_index);
//
//   static int _index(TabController controller) => controller.index;
// }
//
// extension RestorableValueProviderExtension<T> on RestorableValue<T> {
//   ProviderListenable<T> get provider => _RestorableValueProvider(this);
//
//   ProviderListenable<R> select<R>(R Function(T value) selector) => provider.select(selector);
// }
//
// extension TextEditingValueProviderListenableExtensions on ProviderListenable<TextEditingValue> {
//   ProviderListenable<String> get text => select(_selectText);
//
//   static String _selectText(TextEditingValue value) => value.text;
// }
//
// class _ListenableProvider<T extends Listenable> extends SourceProviderListenable<T, T> {
//   const _ListenableProvider(super.source);
//
//   @override
//   T get state => source;
//
//   @override
//   void Function() listen(void Function(T state) listener) {
//     void onChange() => listener(source);
//     source.addListener(onChange);
//     return () => source.removeListener(onChange);
//   }
// }
//
// class _RestorableValueProvider<T> extends SourceProviderListenable<RestorableValue<T>, T> {
//   const _RestorableValueProvider(super.source);
//
//   @override
//   T get state => source.value;
//
//   @override
//   void Function() listen(void Function(T state) listener) {
//     void onChange() => listener(source.value);
//     source.addListener(onChange);
//     return () => source.removeListener(onChange);
//   }
// }
