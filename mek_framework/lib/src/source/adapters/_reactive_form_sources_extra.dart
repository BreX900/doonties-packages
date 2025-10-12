part of '../source.dart';

typedef FormArrayState<C extends AbstractControl, V> = _FormCollectionState<List<C>, List<V?>>;
typedef FormGroupState<C extends AbstractControl, V> =
    _FormCollectionState<Map<String, C>, Map<String, V?>>;

extension FormArrayStateSource<V> on FormArray<V> {
  Source<FormArrayState<AbstractControl, V>> get source => _FormArrayStateSource(this);
}

extension FormArrayStateSourceExtensions<C extends AbstractControl, V>
    on Source<FormArrayState<C, V>> {
  Source<List<C>> get controls => select(_controls);
  Source<bool> containsControl(FormControl<V> control) => selectWith(control, _containsControl);

  static List<C> _controls<C extends AbstractControl, T>(FormArrayState<C, T> state) =>
      state.controls;
  static bool _containsControl<C extends AbstractControl, V>(
    FormControl<V> control,
    FormArrayState<C, V> state,
  ) => state.controls.contains(control);
}

extension FormGroupStateSource on FormGroup {
  Source<FormGroupState> get source => _FormGroupStateSource(this);
}

extension FormGroupStateSourceExtensions<C extends AbstractControl<V>, V>
    on Source<FormGroupState<C, V>> {
  Source<Map<String, C>> get controls => select(_controls);

  static Map<String, C> _controls<C extends AbstractControl<V>, V>(FormGroupState<C, V> state) =>
      state.controls;
}

extension FormListStateProvider<C extends AbstractControl<V>, V> on FormList<C, V> {
  Source<FormArrayState<C, V>> get source => _FormListStateProvider(this);
}

extension FormMapStateProvider<C extends AbstractControl<V>, V> on FormMap<C, V> {
  Source<FormGroupState<C, V>> get source => _FormMapStateProvider(this);
}

class _FormListStateProvider<C extends AbstractControl<V>, V>
    extends _FormCollectionStateSource<FormList<C, V>, List<C>, List<V>> {
  _FormListStateProvider(super.control);

  @override
  List<C> get controls => control.controls;
}

class _FormMapStateProvider<C extends AbstractControl<V>, V>
    extends _FormCollectionStateSource<FormMap<C, V>, Map<String, C>, Map<String, V>> {
  _FormMapStateProvider(super.control);

  @override
  Map<String, C> get controls => control.controls;
}

// ignore: missing_override_of_must_be_overridden
class _FormArrayStateSource<V>
    extends _FormCollectionStateSource<FormArray<V>, List<AbstractControl<V>>, List<V?>> {
  _FormArrayStateSource(super.control);

  @override
  List<AbstractControl<V>> get controls => control.controls;
}

// ignore: missing_override_of_must_be_overridden
class _FormGroupStateSource
    extends
        _FormCollectionStateSource<
          FormGroup,
          Map<String, AbstractControl<Object?>>,
          Map<String, Object?>
        > {
  _FormGroupStateSource(super.control);

  @override
  Map<String, AbstractControl<Object?>> get controls => control.controls;
}

class _FormCollectionState<C, V> extends AbstractControlState<V> {
  final C controls;

  const _FormCollectionState({
    required super.value,
    required super.pristine,
    required super.touched,
    required super.errors,
    required super.status,
    required super.isValueInitial,
    required this.controls,
  });

  @override
  List<Object?> get props => super.props..add(controls);
}

abstract class _FormCollectionStateSource<S extends FormControlCollection, C, V>
    extends _AbstractControlStateSourceBase<S, _FormCollectionState<C, V>> {
  _FormCollectionStateSource(super.control);

  C get controls;

  @override
  Stream<List<AbstractControl<Object?>>>? get changes => control.collectionChanges;

  @override
  _FormCollectionState<C, V> read() {
    return _FormCollectionState(
      value: control.value,
      pristine: control.pristine,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
      isValueInitial: control.isValueInitial,
      controls: controls,
    );
  }
}
