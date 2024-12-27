import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension DebouncedNotifierProviderExtension<T> on ProviderListenable<DebouncedState<T>> {
  ProviderListenable<bool> get isPending => select(_isPending);
  ProviderListenable<T> get value => select(_value);

  static bool _isPending<T>(DebouncedState<T> state) => state.isPending;
  static T _value<T>(DebouncedState<T> state) => state.value;
}

class DebouncedState<T> extends Equatable {
  final bool isPending;
  final T value;

  const DebouncedState({required this.isPending, required this.value});

  DebouncedState<T> toPending() => DebouncedState(isPending: true, value: value);

  DebouncedState<T> toCompleted(T value) => DebouncedState(isPending: false, value: value);

  @override
  List<Object?> get props => [isPending, value];
}

class DebouncedNotifier<T> extends StateNotifier<DebouncedState<T>> {
  final Duration _duration;
  Timer? _timer;

  DebouncedNotifier(this._duration, T value)
      : super(DebouncedState(isPending: false, value: value));

  void emitDebounced(T value) {
    _timer?.cancel();
    _timer = Timer(_duration, () => state = state.toCompleted(value));
    state = state.toPending();
  }

  void emitNow(T value) {
    _timer?.cancel();
    state = state.toCompleted(value);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
