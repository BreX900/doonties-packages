import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

extension FutureOfDataAsyncProviderExtension on WidgetRef {
  FutureOr<T> futureOfData<T>(ProviderListenable<AsyncValue<T>> provider) {
    final result = read(provider);
    if (!result.isLoading) return result.requireValue;

    final completer = Completer<T>.sync();
    late ProviderSubscription<AsyncValue<T>> subscription;
    subscription = listenManual(provider, (previous, next) {
      if (next.isLoading) return;
      if (!next.hasValue) return;

      subscription.close();
      completer.complete(next.requireValue);
    });
    return completer.future;
  }
}
