import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:mek/src/data/optional.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:rivertion/rivertion.dart';

extension DebouncedNotifierProviderExtension<T> on SourceListenable<DebouncedState<T>> {
  SourceListenable<bool> get isPending => select(_isPending);
  SourceListenable<Optional<T>?> get pending => select(_pending);
  SourceListenable<T> get value => select(_value);

  static bool _isPending<T>(DebouncedState<T> state) => state.isPending;
  static Optional<T>? _pending<T>(DebouncedState<T> state) => state.pending;
  static T _value<T>(DebouncedState<T> state) => state.value;
}

final class DebouncedState<T> extends Equatable {
  final Optional<T>? pending;
  final T value;

  bool get isPending => pending != null;
  T? get pendingValueOrNull => pending?.value;
  T get requirePendingValue => pending.requireValue;

  const DebouncedState._({required this.pending, required this.value});

  DebouncedState<T> toPending(T value) =>
      DebouncedState._(pending: Optional(value), value: this.value);

  DebouncedState<T> toCompleted(T value) => DebouncedState._(pending: null, value: value);

  @override
  List<Object?> get props => [pending, value];
}

class DebouncedNotifier<T> extends SourceNotifier<DebouncedState<T>> {
  final Duration _duration;
  Timer? _timer;

  DebouncedNotifier(this._duration, T value) : super(DebouncedState._(pending: null, value: value));

  void emitDebounced(T value) {
    final pending = state.pending;
    if (pending != null && pending.value == value) return;
    _timer?.cancel();
    _timer = Timer(_duration, () => state = state.toCompleted(value));
    state = state.toPending(value);
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

extension DebounceReactiveFormsExtensions<T> on FormControl<T> {
  DebouncedNotifier<T> debounce(Duration duration, T seed, {bool isSeedFallback = false}) {
    final notifier = DebouncedNotifier(duration, value ?? seed);
    valueChanges.listen((value) {
      if (isSeedFallback) {
        notifier.emitDebounced(value ?? seed);
      } else {
        if (value == null) return;
        notifier.emitDebounced(value);
      }
    }, onDone: notifier.dispose);
    return notifier;
  }
}
