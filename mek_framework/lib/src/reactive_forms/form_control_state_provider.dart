import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:mekart/mekart.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension FormControlStateProvider<V> on AbstractControl<V> {
  ProviderListenable<FormControlState<V?>> get provider => _AbstractControlStateProvider(this);
}

extension FormControlStateProviderExtensions<V> on ProviderListenable<FormControlState<V>> {
  ProviderListenable<V> get value => select(_value);
  ProviderListenable<MapEntry<String, dynamic>?> get error => select(_error);
  ProviderListenable<ControlStatus> get status => select(_status);

  static T _value<T>(FormControlState<T> state) => state.value;
  static MapEntry<String, dynamic>? _error<T>(FormControlState<T> state) => state.error;
  static ControlStatus _status<T>(FormControlState<T> state) => state.status;
}

extension FormArrayStateProvider<V> on FormArray<V> {
  ProviderListenable<FormArrayState<AbstractControl<V>, V>> get provider =>
      _FormArrayStateProvider(this);
}

extension FormListStateProvider<C extends AbstractControl<V>, V> on FormList<C, V> {
  ProviderListenable<FormArrayState<C, V>> get provider => _FormListStateProvider(this);
}

extension FormArrayStateProviderExtensions<C extends AbstractControl<V>, V>
    on ProviderListenable<FormArrayState<C, V>> {
  ProviderListenable<List<C>> get controls => select(_controls);

  static List<C> _controls<C extends AbstractControl<T>, T>(FormArrayState<C, T> state) =>
      state.controls;
}

extension FormGroupStateProvider on FormGroup {
  ProviderListenable<FormGroupState> get provider => _FormGroupStateProvider(this);
}

extension FormMultiStateProvider<C extends AbstractControl<V>, V> on FormMulti<C, V> {
  ProviderListenable<FormGroupState<C, V>> get provider => _FormMultiStateProvider(this);
}

extension FormGroupStateProviderExtensions<C extends AbstractControl<V>, V>
    on ProviderListenable<FormGroupState<C, V>> {
  ProviderListenable<Map<String, C>> get controls => select(_controls);

  static Map<String, C> _controls<C extends AbstractControl<V>, V>(FormGroupState<C, V> state) =>
      state.controls;
}

class FormControlState<V> with EquatableAndDescribable {
  final V value;
  final bool touched;
  final Map<String, dynamic> errors;
  final ControlStatus status;

  bool get hasErrors => errors.isNotEmpty;

  MapEntry<String, dynamic>? get error {
    if (!hasErrors || !_showErrors) return null;
    return errors.entries.first;
  }

  bool get _showErrors => status == ControlStatus.invalid && touched;

  const FormControlState({
    required this.value,
    required this.touched,
    required this.errors,
    required this.status,
  });

  @override
  Map<String, Object?> get props =>
      {'value': value, 'touched': touched, 'errors': errors, 'status': status};
}

typedef FormArrayState<C extends AbstractControl<V>, V> = _FormCollectionState<List<C>, List<V?>>;
typedef FormGroupState<C extends AbstractControl<V>, V>
    = _FormCollectionState<Map<String, C>, Map<String, V?>>;

class _FormCollectionState<C, V> extends FormControlState<V> {
  final C controls;

  const _FormCollectionState({
    required super.value,
    required super.touched,
    required super.errors,
    required super.status,
    required this.controls,
  });

  @override
  Map<String, Object?> get props => super.props..['controls'] = controls;
}

class _AbstractControlStateProvider<V>
    extends _AbstractControlStateProviderBase<AbstractControl<V>, FormControlState<V?>> {
  _AbstractControlStateProvider(super.source);

  @override
  FormControlState<V?> get state {
    return FormControlState(
      value: source.value,
      touched: source.touched,
      errors: source.errors,
      status: source.status,
    );
  }
}

class _FormArrayStateProvider<V>
    extends _FormCollectionStateProvider<FormArray<V>, List<AbstractControl<V>>, List<V>> {
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

class _FormMultiStateProvider<C extends AbstractControl<V>, V>
    extends _FormCollectionStateProvider<FormMulti<C, V>, Map<String, C>, Map<String, V>> {
  _FormMultiStateProvider(super.source);

  @override
  Map<String, C> get controls => source.controls;
}

abstract class _FormCollectionStateProvider<S extends FormControlCollection, C, V>
    extends _AbstractControlStateProviderBase<S, _FormCollectionState<C, V>> {
  _FormCollectionStateProvider(super.source);

  C get controls;

  @override
  Stream<List<AbstractControl<Object?>>>? get collectionChanges => source.collectionChanges;

  @override
  _FormCollectionState<C, V> get state {
    return _FormCollectionState(
      value: source.value,
      touched: source.touched,
      errors: source.errors,
      status: source.status,
      controls: controls,
    );
  }
}

abstract class _AbstractControlStateProviderBase<C extends AbstractControl<Object?>,
    S extends FormControlState<Object?>> extends SourceProviderListenable<C, S> {
  _AbstractControlStateProviderBase(super.source);

  @override
  S get state;

  Stream<List<AbstractControl<Object?>>>? get collectionChanges => null;

  @override
  void Function() listen(void Function(S state) listener) {
    void onChanges(_) => listener(state);

    final collectionChanges = this.collectionChanges;
    final subscriptions = [
      source.statusChanged.listen(onChanges),
      source.valueChanges.listen(onChanges),
      source.touchChanges.listen(onChanges),
      if (collectionChanges != null) collectionChanges.listen(onChanges),
    ];
    return () {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    };
  }
}
