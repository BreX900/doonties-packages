import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';

abstract final class Observers {
  static const ProviderObserver provider = _ProviderObserver();

  static void attachAll() {
    PlatformDispatcher.instance.onError = _onPlatformError;
    FlutterError.presentError = _onFlutterError;
    Bloc.observer = const _BlocObserver();
  }

  static bool _onPlatformError(Object error, StackTrace stackTrace) {
    lg.severe('Platform error', error, stackTrace);
    return true;
  }

  static bool _onFlutterError(FlutterErrorDetails details) {
    lg.severe('Flutter error', details);
    return true;
  }
}

class _ProviderObserver extends ProviderObserver {
  const _ProviderObserver();

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    super.didUpdateProvider(provider, previousValue, newValue, container);

    if (newValue is! AsyncError) return;

    lg.severe(
      'Exception caught by $provider'
      '\npreviousValue: ${_stringifyData(previousValue)}'
      '\nnewValue: ${_stringifyData(newValue)}',
      newValue.error,
      newValue.stackTrace,
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    super.providerDidFail(provider, error, stackTrace, container);

    lg.severe('Exception caught by $provider', error, stackTrace);
  }

  String _stringifyData(Object? data) {
    return data.toString().split('\n').take(32).join(' ');
  }
}

class _BlocObserver extends BlocObserver {
  const _BlocObserver();

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    lg.severe('Exception caught by ${bloc.runtimeType}#$bloc', error, stackTrace);
  }
}
