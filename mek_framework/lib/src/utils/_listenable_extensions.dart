import 'package:flutter/foundation.dart';

extension ListenablePickerExtension<T extends Listenable> on T {
  ValueListenable<R> $pick<R>(R Function(T listenable) picker) => _ListenablePicker(this, picker);
}

extension ValueListenableSelectorExtension<T> on ValueListenable<T> {
  ValueListenable<R> $select<R>(R Function(T listenable) picker) =>
      _ValueListenableSelector(this, picker);
}

@immutable
class _ListenablePicker<T extends Listenable, R> extends ValueListenable<R> {
  final T listenable;
  final R Function(T listenable) picker;

  const _ListenablePicker(this.listenable, this.picker);

  @override
  void addListener(VoidCallback listener) => listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => listenable.removeListener(listener);

  @override
  R get value => picker(listenable);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ListenablePicker<T, R> &&
          runtimeType == other.runtimeType &&
          listenable == other.listenable &&
          picker == other.picker;

  @override
  int get hashCode => Object.hash(runtimeType, listenable, picker);
}

@immutable
class _ValueListenableSelector<T, R> extends ValueListenable<R> {
  final ValueListenable<T> listenable;
  final R Function(T listenable) selector;

  const _ValueListenableSelector(this.listenable, this.selector);

  @override
  void addListener(VoidCallback listener) => listenable.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => listenable.removeListener(listener);

  @override
  R get value => selector(listenable.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ValueListenableSelector<T, R> &&
          runtimeType == other.runtimeType &&
          listenable == other.listenable &&
          selector == other.selector;

  @override
  int get hashCode => Object.hash(runtimeType, listenable, selector);
}
