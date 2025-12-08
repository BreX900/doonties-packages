// Version: 3.0.0

part of 'source.dart';

extension SourceAbstractControlExtension<C extends AbstractControl<T>, T> on C {
  AbstractControlSource<C, T> get source => AbstractControlSource._(this);
}

final class AbstractControlSource<C extends AbstractControl<T>, T> {
  final C control;

  SourceListenable<ControlStatus> get status => _onStatus.select(_status);
  SourceListenable<bool> get pristine => _onStatus.select(_pristine);
  SourceListenable<bool> get dirty => _onStatus.select(_dirty);
  SourceListenable<Map<String, Object>> get errors => _onStatus.select(_errors);
  SourceListenable<bool> get hasErrors => _onStatus.select(_hasErrors);
  SourceListenable<bool> hasError(String errorCode, [String? path]) =>
      _onStatus.selectWith((errorCode, path), _hasError);
  SourceListenable<Object?> getError(String errorCode, [String? path]) =>
      _onStatus.selectWith((errorCode, path), _getError);

  SourceListenable<T?> get value => _AbstractControlValueSourceListenable(control);
  SourceListenable<bool> get isEmpty => value.select(_isEmpty);

  SourceListenable<bool> get touched => _AbstractControlTouchSourceListenable(control);

  AbstractControlSource._(this.control);

  SourceListenable<AbstractControl<Object?>> get _onStatus =>
      _AbstractControlStatusSourceListenable(control);

  static ControlStatus _status(AbstractControl<Object?> control) => control.status;
  static bool _pristine(AbstractControl<Object?> control) => control.pristine;
  static bool _dirty(AbstractControl<Object?> control) => control.dirty;
  static Map<String, Object> _errors(AbstractControl<Object?> control) => control.errors;
  static bool _hasErrors(AbstractControl<Object?> control) => control.hasErrors;
  static bool _hasError((String, String?) arg, AbstractControl<Object?> control) =>
      control.hasError(arg.$1, arg.$2);
  static Object? _getError((String, String?) arg, AbstractControl<Object?> control) =>
      control.getError(arg.$1, arg.$2);

  static bool _isEmpty(Object? value) => switch (value) {
    null => true,
    String() => value.isEmpty,
    Iterable() => value.isEmpty,
    Map() => value.isEmpty,
    _ => false,
  };
}

extension SourcesFormGroupExtensions on AbstractControlSource<FormGroup, Map<String, Object?>> {
  SourceListenable<Map<String, AbstractControl<Object?>>> get controls =>
      _FormControlCollectionSourceListenable(control, _controls);

  static Map<String, AbstractControl<Object?>> _controls(FormGroup control) => control.controls;
}

extension SourcesFormArrayExtensions<T> on AbstractControlSource<FormArray<T>, List<T?>> {
  SourceListenable<List<AbstractControl<T>>> get controls =>
      _FormControlCollectionSourceListenable(control, _controls);

  static List<AbstractControl<T>> _controls<T>(FormArray<T> control) => control.controls;
}

extension ControlStatusSourceExtensions on SourceListenable<ControlStatus> {
  SourceListenable<bool> get pending => select(_pending);
  SourceListenable<bool> get valid => select(_valid);
  SourceListenable<bool> get invalid => select(_invalid);
  SourceListenable<bool> get disabled => select(_disabled);
  SourceListenable<bool> get enabled => select(_enabled);

  static bool _pending(ControlStatus status) => status == ControlStatus.pending;
  static bool _valid(ControlStatus status) => status == ControlStatus.valid;
  static bool _invalid(ControlStatus status) => status == ControlStatus.invalid;
  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;
  static bool _enabled(ControlStatus status) => !_disabled(status);
}

final class _AbstractControlStatusSourceListenable
    extends SourceListenable<AbstractControl<Object?>> {
  final AbstractControl<Object?> _control;

  _AbstractControlStatusSourceListenable(this._control);

  @override
  SourceSubscription<AbstractControl<Object?>> listen(
    SourceListener<AbstractControl<Object?>> listener,
  ) {
    final subscription = _control.statusChanged.listen((_) {
      listener(_control, _control);
    });
    return SourceSubscriptionBuilder(() => _control, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlStatusSourceListenable &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control);

  @override
  int get hashCode => Object.hash(runtimeType, _control);
}

final class _AbstractControlValueSourceListenable<T> extends SourceListenable<T?> {
  final AbstractControl<T> _control;

  _AbstractControlValueSourceListenable(this._control);

  @override
  SourceSubscription<T?> listen(SourceListener<T?> listener) {
    var current = _control.value;
    final subscription = _control.valueChanges.listen((value) {
      final previous = current;
      current = value;
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlValueSourceListenable<T> &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control);

  @override
  int get hashCode => Object.hash(runtimeType, _control);
}

final class _AbstractControlTouchSourceListenable extends SourceListenable<bool> {
  final AbstractControl<Object?> _control;

  _AbstractControlTouchSourceListenable(this._control);

  @override
  SourceSubscription<bool> listen(SourceListener<bool> listener) {
    var current = _control.touched;
    final subscription = _control.touchChanges.listen((value) {
      final previous = current;
      current = value;
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AbstractControlTouchSourceListenable &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control);

  @override
  int get hashCode => Object.hash(runtimeType, _control);
}

final class _FormControlCollectionSourceListenable<C extends FormControlCollection, R>
    extends SourceListenable<R> {
  final C _control;
  final R Function(C control) _selector;

  _FormControlCollectionSourceListenable(this._control, this._selector);

  @override
  SourceSubscription<R> listen(SourceListener<R> listener) {
    var current = _selector(_control);
    final subscription = _control.collectionChanges.listen((value) {
      final previous = current;
      current = _selector(_control);
      if (previous == current) return;
      listener(previous, current);
    });
    return SourceSubscriptionBuilder(() => current, subscription.cancel);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FormControlCollectionSourceListenable<C, R> &&
          runtimeType == other.runtimeType &&
          identical(_control, other._control) &&
          _selector == other._selector;

  @override
  int get hashCode => Object.hash(runtimeType, _control, _selector);
}
