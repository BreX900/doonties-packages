import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';

abstract final class Observers {
  static const ProviderObserver provider = _ProviderObserver();

  static void attachAll() {
    PlatformDispatcher.instance.onError = _handlePlatformError;
    FlutterError.presentError = _handleFlutterError;
  }

  static bool _handlePlatformError(Object error, StackTrace stackTrace) {
    lg.severe('Platform error', error, stackTrace);
    return true;
  }

  static bool _handleFlutterError(FlutterErrorDetails details) {
    lg.severe('Flutter error', details);
    return true;
  }
}

final class _ProviderObserver extends ProviderObserver {
  const _ProviderObserver();

  // @override
  // void didUpdateProvider(
  //   ProviderObserverContext context,
  //   Object? previousValue,
  //   Object? newValue,
  // ) {
  //   if (newValue is! AsyncError) return;
  //
  //   lg.severe(
  //     'Exception caught by $provider'
  //     '\npreviousValue: ${_stringifyData(previousValue)}'
  //     '\nnewValue: ${_stringifyData(newValue)}',
  //     newValue.error,
  //     newValue.stackTrace,
  //   );
  // }

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    print('providerDidFail');
    lg.severe('Exception caught by ${context.provider}', error, stackTrace);
  }

  // String _stringifyData(Object? data) {
  //   return data.toString().split('\n').take(32).join(' ');
  // }
}
