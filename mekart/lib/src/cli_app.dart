import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mekart/src/cli_utils.dart';

abstract class CliApp {
  FutureOr<void> run();
}

abstract class App {
  ProviderRef? _ref;
  ProviderRef get ref => _ref!;

  FutureOr<void> run();
}

void runApp(App app) {
  runWithRef((ref) async {
    app._ref = ref;
    await app.run();
    app._ref = null;
  });
}

void runCliApp(CliApp Function(ProviderRef ref) creator) {
  final logSub = _listenLogRecords();
  final container = ProviderContainer();

  Zone.current.runGuarded(() async {
    try {
      final app = creator(container);
      await app.run();
    } finally {
      container.clear();
      await logSub.cancel();
    }
  });
}

void runWithRef(FutureOr<void> Function(ProviderRef ref) body) {
  final logSub = _listenLogRecords();
  final container = ProviderContainer();

  Zone.current.runGuarded(() async {
    try {
      await body(container);
    } finally {
      container.clear();
      await logSub.cancel();
    }
  });
}

StreamSubscription<LogRecord> _listenLogRecords() {
  return lg.onRecord.listen((record) {
    if (record.level < Level.SEVERE) {
      stdout.writeln(record);
      if (record.error != null) stdout.writeln(record.error);
      if (record.stackTrace != null) stdout.writeln(record.stackTrace);
    } else {
      stdout.writeln(record);
      stderr.writeln('${record.error}\n${record.stackTrace}');
      exitCode = 1;
    }
  });
}

class ProviderOverride<T> {
  final Provider<T> provider;
  final T value;

  ProviderOverride(this.provider, this.value);

  ProviderElement<T> create() => _ValueProviderElement(value);
}

class ProviderContainer implements ProviderRef {
  var _providers = <Provider<Object?>, ProviderElement<Object?>>{};

  ProviderContainer({
    List<ProviderOverride<dynamic>> overrides = const [],
  }) {
    apply(overrides: overrides);
  }

  @override
  T read<T>(Provider<T> provider) {
    final element = _providers.putIfAbsent(provider, () => provider.create()) as ProviderElement<T>;
    return element.read(this);
  }

  void apply({List<ProviderOverride<Object?>> overrides = const []}) {
    for (final override in overrides) {
      _providers[override.provider] = override.create();
    }
  }

  void clear() {
    for (final instance in _providers.values) {
      instance.dispose();
    }
    _providers = const {};
  }
}

abstract class ProviderRef {
  T read<T>(Provider<T> provider);
}

class Provider<T> {
  final ProviderElement<T> Function() _creator;

  factory Provider.value(T value) => Provider._(() => _ValueProviderElement(value));

  factory Provider.factory(T Function(ProviderRef ref) creator) =>
      Provider._(() => _FactoryProviderElement(creator));

  factory Provider.disposable(
    T Function(ProviderRef ref) creator,
    void Function(T instance) disposer,
  ) =>
      Provider._(() => _DisposableProviderElement(creator, disposer));

  const Provider._(this._creator);

  ProviderElement<T> create() => _creator();
}

abstract class ProviderElement<T> {
  const ProviderElement._();

  T read(ProviderRef ref);

  void dispose() {}
}

class _ValueProviderElement<T> extends ProviderElement<T> {
  final T value;

  const _ValueProviderElement(this.value) : super._();

  @override
  T read(ProviderRef ref) => value;
}

class _FactoryProviderElement<T> extends ProviderElement<T> {
  final T Function(ProviderRef ref) creator;

  const _FactoryProviderElement(this.creator) : super._();

  @override
  T read(ProviderRef ref) => creator(ref);
}

class _DisposableProviderElement<T> extends ProviderElement<T> {
  final T Function(ProviderRef ref) creator;
  final void Function(T instance) disposer;

  _DisposableProviderElement(this.creator, this.disposer) : super._();

  T? _instance;

  @override
  T read(ProviderRef ref) => _instance ??= creator(ref);

  @override
  void dispose() {
    final instance = _instance;
    if (instance == null) return;
    disposer(instance);
    _instance = null;
  }
}
