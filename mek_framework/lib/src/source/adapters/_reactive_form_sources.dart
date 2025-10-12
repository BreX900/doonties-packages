part of '../source.dart';

extension AbstractControlStateSource<V> on AbstractControl<V> {
  Source<AbstractControlState<V?>> get source => _AbstractControlStateSource(this);

  Source<R> select<R>(R Function(AbstractControl<V> control) selector) =>
      _FormControlSource(this).select(selector);
}

extension ControlStateSource<C extends AbstractControl<Object?>> on C {
  Source<R> select<R>(R Function(C control) selector) => _FormControlSource(this).select(selector);
}

extension AbstractControlStateSourceExtensions<V> on Source<AbstractControlState<V>> {
  Source<bool> get hasValue => select(_hasValue);
  Source<V?> get value => select(_value);
  Source<bool> get pristine => select(_pristine);
  Source<bool> get dirty => select(_dirty);
  Source<bool> get touched => select(_touched);
  Source<ControlStatus> get status => select(_status);
  Source<MapEntry<String, Object>?> get error => select(_error);
  Source<bool> get isValueInitial => select(_isValueInitial);
  Source<bool> get isEmpty => select(_isEmpty);

  static bool _hasValue<V>(AbstractControlState<V> state) => state.value != null;
  static V? _value<V>(AbstractControlState<V> state) => state.value;
  static bool _pristine<V>(AbstractControlState<V> state) => state.pristine;
  static bool _dirty<V>(AbstractControlState<V> state) => state.dirty;
  static bool _touched<V>(AbstractControlState<V> state) => state.touched;
  static ControlStatus _status<V>(AbstractControlState<V> state) => state.status;
  static MapEntry<String, Object>? _error<V>(AbstractControlState<V> state) => state.error;
  static bool _isValueInitial<V>(AbstractControlState<V> state) => state.isValueInitial;
  static bool _isEmpty(AbstractControlState<Object?> state) {
    final value = state.value;
    return value == null ||
        (value is String && value.isEmpty) ||
        (value is Iterable && value.isEmpty) ||
        (value is Map && value.isEmpty);
  }
}

extension ControlStatusSourceExtensions on Source<ControlStatus> {
  Source<bool> get enabled => select(_enabled);
  Source<bool> get disabled => select(_disabled);
  Source<bool> get valid => select(_valid);

  static bool _enabled(ControlStatus status) => status != ControlStatus.disabled;
  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;
  static bool _valid(ControlStatus status) => status == ControlStatus.valid;
}

extension FormControlStateSource<V> on FormControl<V> {
  Source<FormControlState<V>> get source => _FormControlStateSource(this);
}

extension FormControlStateSourceExtensions<V> on Source<FormControlState<V?>> {
  Source<bool> get hasFocus => select(_hasFocus);

  static bool _hasFocus<V>(FormControlState<V?> state) => state.hasFocus;
}

class AbstractControlState<V> with EquatableMixin {
  final V? value;
  final bool pristine;
  final bool touched;
  final Map<String, Object> errors;
  final ControlStatus status;
  final bool isValueInitial;

  bool get dirty => !pristine;
  bool get hasErrors => errors.isNotEmpty;

  MapEntry<String, Object>? get error {
    if (!hasErrors || !_showErrors) return null;
    return errors.entries.first;
  }

  bool get _showErrors => status == ControlStatus.invalid && touched;

  const AbstractControlState({
    required this.value,
    required this.pristine,
    required this.touched,
    required this.errors,
    required this.status,
    required this.isValueInitial,
  });

  @override
  List<Object?> get props => [value, pristine, touched, errors, status, isValueInitial];
}

class FormControlState<V> extends AbstractControlState<V?> {
  final bool hasFocus;

  const FormControlState({
    required super.value,
    required super.pristine,
    required super.touched,
    required super.errors,
    required super.status,
    required super.isValueInitial,
    required this.hasFocus,
  });

  @override
  List<Object?> get props => super.props..add(hasFocus);
}

// ignore: missing_override_of_must_be_overridden
class _AbstractControlStateSource<V>
    extends _AbstractControlStateSourceBase<AbstractControl<V>, AbstractControlState<V?>> {
  _AbstractControlStateSource(super.control);

  @override
  AbstractControlState<V?> read() {
    return AbstractControlState(
      value: control.value,
      pristine: control.pristine,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
      isValueInitial: control.isValueInitial,
    );
  }
}

// ignore: missing_override_of_must_be_overridden
class _FormControlStateSource<V>
    extends _AbstractControlStateSourceBase<FormControl<V>, FormControlState<V>> {
  _FormControlStateSource(super.control);

  @override
  Stream<Object?>? get changes => control.focusChanges;

  @override
  FormControlState<V> read() {
    return FormControlState(
      value: control.value,
      pristine: control.pristine,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
      isValueInitial: control.isValueInitial,
      hasFocus: control.hasFocus,
    );
  }
}

abstract class _AbstractControlStateSourceBase<TControl extends AbstractControl<Object?>,
    TState extends AbstractControlState<Object?>> extends Source<TState> with EquatableMixin {
  final TControl control;

  _AbstractControlStateSourceBase(this.control);

  Stream<Object?>? get changes => null;

  TState read();

  @override
  SourceSubscription<TState> listen(SourceListener<TState> listener) {
    var current = read();
    void onChange(_) {
      final previous = current;
      current = read();
      if (previous == current) return;
      Zone.current.runBinaryGuarded(listener, previous, current);
    }

    return _ControlSubscription(
      reader: () => current,
      statusSubscription: control.statusChanged.listen(onChange),
      valueSubscription: control.valueChanges.listen(onChange),
      touchSubscription: control.touchChanges.listen(onChange),
      changesSubscription: changes?.listen(onChange),
    );
  }

  @override
  List<Object?> get props => [control];
}

class _FormControlSource<TControl extends AbstractControl<Object?>> extends Source<TControl>
    with EquatableMixin {
  final TControl control;

  _FormControlSource(this.control);

  Stream<Object?>? get changes => null;

  @override
  SourceSubscription<TControl> listen(SourceListener<TControl> listener) {
    void onChange(_) => Zone.current.runBinaryGuarded(listener, control, control);

    return _ControlSubscription(
      reader: () => control,
      statusSubscription: control.statusChanged.listen(onChange),
      valueSubscription: control.valueChanges.listen(onChange),
      touchSubscription: control.touchChanges.listen(onChange),
      changesSubscription: changes?.listen(onChange),
    );
  }

  @override
  List<Object?> get props => [control];
}

final class _ControlSubscription<T> extends SourceSubscription<T> {
  final ValueGetter<T> reader;
  final StreamSubscription<ControlStatus> statusSubscription;
  final StreamSubscription<Object?> valueSubscription;
  final StreamSubscription<bool> touchSubscription;
  final StreamSubscription<Object?>? changesSubscription;

  _ControlSubscription({
    required this.reader,
    required this.statusSubscription,
    required this.valueSubscription,
    required this.touchSubscription,
    required this.changesSubscription,
  });

  @override
  T read() {
    assert(SourceSubscription.debugIsCancelled(this));
    return reader();
  }

  @override
  void cancel() {
    unawaited(statusSubscription.cancel());
    unawaited(valueSubscription.cancel());
    unawaited(touchSubscription.cancel());
    unawaited(changesSubscription?.cancel());
    super.cancel();
  }
}
