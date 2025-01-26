import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:mekart/mekart.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension AbstractControlStateProvider<V> on AbstractControl<V> {
  ProviderListenable<AbstractControlState<V?>> get provider => _AbstractControlStateProvider(this);
}

extension AbstractControlStateProviderExtensions<V> on ProviderListenable<AbstractControlState<V>> {
  ProviderListenable<bool> get hasValue => select(_hasValue);
  ProviderListenable<V> get value => select(_value);
  ProviderListenable<bool> get pristine => select(_pristine);
  ProviderListenable<bool> get dirty => select(_dirty);
  ProviderListenable<bool> get touched => select(_touched);
  ProviderListenable<ControlStatus> get status => select(_status);
  ProviderListenable<MapEntry<String, Object>?> get error => select(_error);
  ProviderListenable<bool> get isValueInitial => select(_isValueInitial);

  static bool _hasValue<V>(AbstractControlState<V> state) => state.value != null;
  static V _value<V>(AbstractControlState<V> state) => state.value;
  static bool _pristine<V>(AbstractControlState<V> state) => state.pristine;
  static bool _dirty<V>(AbstractControlState<V> state) => state.dirty;
  static bool _touched<V>(AbstractControlState<V> state) => state.touched;
  static ControlStatus _status<V>(AbstractControlState<V> state) => state.status;
  static MapEntry<String, Object>? _error<V>(AbstractControlState<V> state) => state.error;
  static bool _isValueInitial<V>(AbstractControlState<V> state) => state.isValueInitial;
}

extension ProviderListenableControlStatusExtensions on ProviderListenable<ControlStatus> {
  ProviderListenable<bool> get enabled => select(_enabled);
  ProviderListenable<bool> get disabled => select(_disabled);

  static bool _enabled(ControlStatus status) => status != ControlStatus.disabled;
  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;
}

extension FormControlStateProvider<V> on FormControl<V> {
  ProviderListenable<FormControlState<V>> get provider => _FormControlStateProvider(this);
}

extension FormControlStateProviderExtensions<V> on ProviderListenable<FormControlState<V?>> {
  ProviderListenable<bool> get hasFocus => select(_hasFocus);

  static bool _hasFocus<V>(FormControlState<V?> state) => state.hasFocus;
}

extension FormArrayStateProvider<V> on FormArray<V> {
  ProviderListenable<FormArrayState<AbstractControl<Object?>, V>> get provider =>
      _FormArrayStateProvider(this);
}

extension FormListStateProvider<C extends AbstractControl<V>, V> on FormList<C, V> {
  ProviderListenable<FormArrayState<C, V>> get provider => _FormListStateProvider(this);
}

extension FormArrayStateProviderExtensions<C extends AbstractControl, V>
    on ProviderListenable<FormArrayState<C, V>> {
  ProviderListenable<List<C>> get controls => select(_controls);

  static List<C> _controls<C extends AbstractControl, T>(FormArrayState<C, T> state) =>
      state.controls;
}

extension FormGroupStateProvider on FormGroup {
  ProviderListenable<FormGroupState> get provider => _FormGroupStateProvider(this);
}

extension FormMapStateProvider<C extends AbstractControl<V>, V> on FormMap<C, V> {
  ProviderListenable<FormGroupState<C, V>> get provider => _FormMapStateProvider(this);
}

extension FormGroupStateProviderExtensions<C extends AbstractControl<V>, V>
    on ProviderListenable<FormGroupState<C, V>> {
  ProviderListenable<Map<String, C>> get controls => select(_controls);

  static Map<String, C> _controls<C extends AbstractControl<V>, V>(FormGroupState<C, V> state) =>
      state.controls;
}

class AbstractControlState<V> with EquatableAndDescribable {
  final V value;
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
  Map<String, Object?> get props => {
        'value': value,
        'pristine': pristine,
        'touched': touched,
        'errors': errors,
        'status': status,
        'isValueInitial': isValueInitial,
      };
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
  Map<String, Object?> get props => super.props..['hasFocus'] = hasFocus;
}

typedef FormArrayState<C extends AbstractControl, V> = _FormCollectionState<List<C>, List<V?>>;
typedef FormGroupState<C extends AbstractControl, V>
    = _FormCollectionState<Map<String, C>, Map<String, V?>>;

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
  Map<String, Object?> get props => super.props
    ..['controls'] = controls
    ..['isValueInitial'] = isValueInitial;
}

class _AbstractControlStateProvider<V>
    extends _AbstractControlStateProviderBase<AbstractControl<V>, AbstractControlState<V?>> {
  _AbstractControlStateProvider(super.source);

  @override
  AbstractControlState<V?> get state {
    return AbstractControlState(
      value: source.value,
      pristine: source.pristine,
      touched: source.touched,
      errors: source.errors,
      status: source.status,
      isValueInitial: source.isValueInitial,
    );
  }
}

class _FormControlStateProvider<V>
    extends _AbstractControlStateProviderBase<FormControl<V>, FormControlState<V>> {
  _FormControlStateProvider(super.source);

  @override
  Stream<Object?>? get changes => source.focusChanges;

  @override
  FormControlState<V> get state {
    return FormControlState(
      value: source.value,
      pristine: source.pristine,
      touched: source.touched,
      errors: source.errors,
      status: source.status,
      isValueInitial: source.isValueInitial,
      hasFocus: source.hasFocus,
    );
  }
}

class _FormArrayStateProvider<V>
    extends _FormCollectionStateProvider<FormArray<V>, List<AbstractControl<V>>, List<V?>> {
  _FormArrayStateProvider(super.source);

  @override
  List<AbstractControl<V>> get controls => source.controls;
}

class _FormListStateProvider<C extends AbstractControl<V>, V>
    extends _FormCollectionStateProvider<FormList<C, V>, List<C>, List<V>> {
  _FormListStateProvider(super.source);

  @override
  List<C> get controls => source.controls;
}

class _FormGroupStateProvider extends _FormCollectionStateProvider<FormGroup,
    Map<String, AbstractControl<Object?>>, Map<String, Object?>> {
  _FormGroupStateProvider(super.source);

  @override
  Map<String, AbstractControl<Object?>> get controls => source.controls;
}

class _FormMapStateProvider<C extends AbstractControl<V>, V>
    extends _FormCollectionStateProvider<FormMap<C, V>, Map<String, C>, Map<String, V>> {
  _FormMapStateProvider(super.source);

  @override
  Map<String, C> get controls => source.controls;
}

abstract class _FormCollectionStateProvider<S extends FormControlCollection, C, V>
    extends _AbstractControlStateProviderBase<S, _FormCollectionState<C, V>> {
  _FormCollectionStateProvider(super.source);

  C get controls;

  @override
  Stream<List<AbstractControl<Object?>>>? get changes => source.collectionChanges;

  @override
  _FormCollectionState<C, V> get state {
    return _FormCollectionState(
      value: source.value,
      pristine: source.pristine,
      touched: source.touched,
      errors: source.errors,
      status: source.status,
      controls: controls,
      isValueInitial: source.isValueInitial,
    );
  }
}

abstract class _AbstractControlStateProviderBase<C extends AbstractControl<Object?>,
    S extends AbstractControlState<Object?>> extends SourceProviderListenable<C, S> {
  _AbstractControlStateProviderBase(super.source);

  @override
  S get state;

  Stream<Object?>? get changes => null;

  @override
  bool updateShouldNotify(S prev, S next) => prev != next;

  @override
  void Function() listen(void Function(S state) listener) {
    void onChanges(_) => listener(state);

    final changes = this.changes;
    final subscriptions = [
      source.statusChanged.listen(onChanges),
      source.valueChanges.listen(onChanges),
      source.touchChanges.listen(onChanges),
      if (changes != null) changes.listen(onChanges),
    ];
    return () {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    };
  }
}
