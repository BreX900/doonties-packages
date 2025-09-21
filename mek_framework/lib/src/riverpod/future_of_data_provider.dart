import 'dart:async';

// ignore: implementation_imports, depend_on_referenced_packages
import 'package:riverpod/src/framework.dart';

extension FutureOfDataAsyncProviderExtension<T> on ProviderListenable<AsyncValue<T>> {
  ProviderListenable<FutureOr<T>> get futureOfData => _ProviderListenable(this);
}

final class _ProviderListenable<T> with SyncProviderTransformerMixin<AsyncValue<T>, FutureOr<T>> {
  @override
  final ProviderListenable<AsyncValue<T>> source;

  _ProviderListenable(this.source);

  @override
  ProviderTransformer<AsyncValue<T>, FutureOr<T>> transform(
    ProviderTransformerContext<AsyncValue<T>, FutureOr<T>> context,
  ) {
    var completer = Completer<T>.sync();
    return ProviderTransformer(
      initState: (self) {
        final current = context.sourceState.requireValue;
        if (current.hasValue) {
          completer.complete(current.requireValue);
          return current.requireValue;
        }
        return completer.future;
      },
      listener: (self, previousResult, nextResult) {
        final previous = previousResult.requireValue;
        final next = nextResult.requireValue;

        switch (next) {
          case AsyncLoading<T>():
          case AsyncError<T>():
            if (completer.isCompleted) completer = Completer.sync();

          case AsyncData<T>(value: final nextValue):
            if (completer.isCompleted) {
              if (previous.hasValue && previous.requireValue == nextValue) return;
              self.state = AsyncData(next.requireValue);
            } else {
              completer.complete(nextValue);
            }
        }
      },
    );
  }
}
