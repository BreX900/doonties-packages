import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

extension FutureOfDataAsyncProviderExtension on WidgetRef {
  FutureOr<T> futureOfData<T>(ProviderListenable<AsyncValue<T>> provider) {
    final result = read(provider);
    if (result.hasValue) return result.requireValue;

    final completer = Completer<T>.sync();
    late ProviderSubscription<AsyncValue<T>> subscription;
    subscription = listenManual(provider, (previous, next) {
      if (!next.hasValue) return;

      subscription.close();
      completer.complete(next.requireValue);
    });
    return completer.future;
  }
}

// class _Future<T> implements Future<T> {
//   const _Future();
//
//   @override
//   Stream<T> asStream() => Stream.empty();
//
//   @override
//   Future<T> catchError(Function onError, {bool Function(Object error)? test}) => _Future<T>();
//
//   @override
//   Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) => _Future<R>();
//
//   @override
//   Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) => _Future<T>();
//
//   @override
//   Future<T> whenComplete(FutureOr<void> Function() action) => _Future<T>();
// }
