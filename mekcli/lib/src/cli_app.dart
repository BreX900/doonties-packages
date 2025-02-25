import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:mekcli/src/cli_utils.dart';

enum CliExceptionType { executionSkipped, executionEmpty }

class CliException implements Exception {
  final int exitCode;
  final CliExceptionType type;

  CliException.executionSkipped()
      : exitCode = 2,
        type = CliExceptionType.executionSkipped;

  CliException.executionEmpty()
      : exitCode = 3,
        type = CliExceptionType.executionEmpty;

  @override
  String toString() => 'CliException: ${type.name}';
}

abstract class CliApp {
  FutureOr<void> run();
}

abstract class App {
  ProviderRef? _ref;
  ProviderRef get ref => _ref!;

  FutureOr<void> run();
}

void runApp(App app) {
  _runWithRef((container) async {
    app._ref = container;
    await app.run();
    app._ref = null;
  });
}

void runCliApp(CliApp Function(ProviderRef ref) creator) {
  _runWithRef((container) async {
    final app = creator(container);
    await app.run();
  });
}

void runWithRef(FutureOr<void> Function(ProviderRef ref) body) => _runWithRef(body);

void _runWithRef(FutureOr<void> Function(ProviderContainer container) body) {
  final logSub = _listenLogRecords();
  final container = ProviderContainer();

  Zone.current.runGuarded(() async {
    lg.config('Build version: $kBuildName${kBuildNumber != -1 ? '+$kBuildNumber' : ''}');

    try {
      await body(container);
    } on CliException catch (exception) {
      exitCode = exception.exitCode;
    } finally {
      container.dispose();
      await logSub.cancel();
    }
  });
}

StreamSubscription<LogRecord> _listenLogRecords() {
  if (kDebugMode) lg.level = Level.ALL;
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

  ProviderElement<T> create(ProviderContainer container) => _ValueProviderElement(container, value);
}

class ProviderContainer implements ProviderRef {
  var _providers = <Provider<Object?>, ProviderElement<Object?>>{};

  ProviderContainer({
    List<ProviderOverride<dynamic>> overrides = const [],
  }) {
    apply(overrides: overrides);
  }

  @override
  R read<R>(Provider<R> provider) {
    final element =
        _providers.putIfAbsent(provider, () => provider.create(this)) as ProviderElement<R>;
    return element.get();
  }

  void apply({List<ProviderOverride<Object?>> overrides = const []}) {
    for (final override in overrides) {
      _providers[override.provider] = override.create(this);
    }
  }

  void dispose() {
    for (final instance in _providers.values) {
      Zone.current.runGuarded(instance.dispose);
    }
    _providers = const {};
  }
}

abstract class ProviderRef {
  R read<R>(Provider<R> provider);
}

abstract class SingletonProviderRef extends ProviderRef {
  void onDispose(void Function() disposer);
}

class Provider<T> {
  final ProviderElement<T> Function(ProviderContainer container) _creator;

  factory Provider.value(T value) =>
      Provider._((container) => _ValueProviderElement(container, value));

  factory Provider.factory(T Function(ProviderRef ref) creator) =>
      Provider._((container) => _FactoryProviderElement(container, creator));

  factory Provider.singleton(T Function(SingletonProviderRef ref) creator) =>
      Provider._((container) => _SingletonProviderElement(container, creator));

  const Provider._(this._creator);

  ProviderElement<T> create(ProviderContainer container) => _creator(container);
}

abstract class ProviderElement<T> implements ProviderRef {
  ProviderContainer? _container;
  ProviderContainer get container => _container!;

  ProviderElement._(this._container);

  @override
  R read<R>(Provider<R> provider) => container.read(provider);

  T get();

  void dispose() {
    _container = null;
  }
}

class _ValueProviderElement<T> extends ProviderElement<T> {
  final T value;

  _ValueProviderElement(super._container, this.value) : super._();

  @override
  T get() => value;
}

class _FactoryProviderElement<T> extends ProviderElement<T> {
  final T Function(ProviderRef ref) creator;

  _FactoryProviderElement(super._container, this.creator) : super._();

  @override
  T get() => creator(this);
}

class _SingletonProviderElement<T> extends ProviderElement<T> implements SingletonProviderRef {
  final _disposers = <void Function()>[];
  final T Function(SingletonProviderRef ref) creator;

  _SingletonProviderElement(super._container, this.creator) : super._();

  T? _instance;

  @override
  T get() => _instance ??= creator(this);

  @override
  void onDispose(void Function() disposer) => _disposers.add(disposer);

  @override
  void dispose() {
    _disposers.forEach(Zone.current.runGuarded);
    super.dispose();
    _instance = null;
  }
}
