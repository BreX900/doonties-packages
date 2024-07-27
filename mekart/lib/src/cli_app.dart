import 'dart:async';

import 'package:logging/logging.dart';

Future<void> runApp(App app) async {
  await runWithAppRef((ref) async {
    app._ref = ref;
    await app.run();
  });
}

Future<void> runWithAppRef(FutureOr<void> Function(AppRef ref) body) async {
  // ignore: avoid_print
  Logger.root.onRecord.listen((record) => print('$record\n${record.error}\n${record.stackTrace}'));

  final ref = AppRef();

  try {
    await body(ref);
  } finally {
    ref._dispose();
    Logger.root.clearListeners();
  }
}

abstract class App {
  late AppRef _ref;

  AppRef get ref => _ref;

  FutureOr<void> run();
}

class AppRef {
  var _providers = <Provider<Object?>, Object?>{};

  T read<T>(Provider<T> provider) =>
      _providers.putIfAbsent(provider, () => provider.create(this)) as T;

  void _dispose() {
    _providers.forEach((provider, instance) => provider.dispose(instance));
    _providers = const {};
  }
}

abstract class Provider<T> {
  factory Provider(T Function(AppRef ref) creator, [void Function(T instance)? disposer]) =
      _ProviderBuilder<T>;

  const Provider._();

  T create(AppRef app);

  void dispose(T instance);
}

class _ProviderBuilder<T> extends Provider<T> {
  final T Function(AppRef ref) creator;
  final void Function(T instance)? disposer;

  const _ProviderBuilder(this.creator, [this.disposer]) : super._();

  @override
  T create(AppRef ref) => creator(ref);

  @override
  void dispose(T instance) => disposer?.call(instance);
}
