import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mekart/src/cli_utils.dart';

@Deprecated('In favour of runWithAppRef')
Future<void> runApp(App app) async {
  await runWithRef((ref) async {
    app._ref = ref;
    await app.run();
  });
}

Future<void> runWithRef(FutureOr<void> Function(ProviderRef ref) body) async {
  final logSub = lg.onRecord.listen((record) {
    if (record.level < Level.SEVERE) {
      stdout.writeln(record);
      if (record.error != null) stdout.writeln(record.error);
      if (record.stackTrace != null) stdout.writeln(record.stackTrace);
    } else {
      stderr.writeln('$record\n${record.error}\n${record.stackTrace}');
    }
  });

  final container = ProviderContainer();

  try {
    await body(container);
  } finally {
    container.clear();
    await logSub.cancel();
  }
}

abstract class App {
  late ProviderRef _ref;

  ProviderRef get ref => _ref;

  FutureOr<void> run();
}

class ProviderOverride<T> {
  final Provider<T> provider;
  final T value;

  ProviderOverride(this.provider, this.value);
}

class ProviderContainer implements ProviderRef {
  Map<Provider<Object?>, Object?> _providers = {};

  ProviderContainer({
    List<ProviderOverride<dynamic>> overrides = const [],
  }) {
    apply(overrides: overrides);
  }

  @override
  T read<T>(Provider<T> provider) =>
      _providers.putIfAbsent(provider, () => provider.create(this)) as T;

  void apply({List<ProviderOverride<dynamic>> overrides = const []}) {
    for (final override in overrides) {
      _providers[override.provider] = override.value;
    }
  }

  void clear() {
    _providers.forEach((provider, instance) => provider.dispose(instance));
    _providers = {};
  }
}

abstract class ProviderRef {
  T read<T>(Provider<T> provider);
}

// abstract class Disposable {
//   void dispose();
// }

abstract class Provider<T> {
  factory Provider(T Function(ProviderRef ref) creator, [void Function(T instance)? disposer]) =
      _ValueProvider<T>;

  // static Provider from<T extends Disposable>(T Function(ProviderRef ref) creator) =>
  //     _DisposableProvider<T>(creator);

  const Provider._();

  T create(ProviderRef app);

  void dispose(T instance);
}

class _ValueProvider<T> extends Provider<T> {
  final T Function(ProviderRef ref) creator;
  final void Function(T instance)? disposer;

  const _ValueProvider(this.creator, [this.disposer]) : super._();

  @override
  T create(ProviderRef ref) => creator(ref);

  @override
  void dispose(T instance) => disposer?.call(instance);
}

// class _DisposableProvider<T extends Disposable> extends Provider<T> {
//   final T Function(ProviderRef ref) creator;
//
//   const _DisposableProvider(this.creator) : super._();
//
//   @override
//   T create(ProviderRef ref) => creator(ref);
//
//   @override
//   void dispose(T instance) => instance.dispose();
// }
