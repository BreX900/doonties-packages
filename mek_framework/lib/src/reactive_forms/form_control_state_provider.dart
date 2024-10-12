import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:mekart/mekart.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension FormControlStateProvider<T> on AbstractControl<T> {
  ProviderListenable<FormControlState<T>> get provider => _AbstractControlStateProvider(this);
}

extension FormControlStateProviderExtensions<T> on ProviderListenable<FormControlState<T>> {
  ProviderListenable<T?> get value => select(_value);
  ProviderListenable<MapEntry<String, dynamic>?> get error => select(_error);
  ProviderListenable<ControlStatus> get status => select(_status);

  static T? _value<T>(FormControlState<T> state) => state.value;
  static MapEntry<String, dynamic>? _error<T>(FormControlState<T> state) => state.error;
  static ControlStatus _status<T>(FormControlState<T> state) => state.status;
}

extension FormGroupStateProvider on FormGroup {
  ProviderListenable<FormGroupState> get provider => _FormGroupStateProvider(this);
}

extension FormGroupStateProviderExtensions on ProviderListenable<FormGroupState> {
  ProviderListenable<Map<String, AbstractControl<Object?>>> get controls => select(_controls);

  static Map<String, AbstractControl<Object?>> _controls<T>(FormGroupState state) => state.controls;
}

class FormControlState<T> with EquatableAndDescribable {
  final T? value;
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

class FormGroupState extends FormControlState<Map<String, Object?>> {
  final Map<String, AbstractControl<Object?>> controls;

  const FormGroupState({
    required super.value,
    required super.touched,
    required super.errors,
    required super.status,
    required this.controls,
  });

  @override
  Map<String, Object?> get props => super.props..['controls'] = controls;
}

class _AbstractControlStateProvider<T>
    extends SourceProviderListenable<AbstractControl<T>, FormControlState<T>> {
  _AbstractControlStateProvider(super.source);

  @override
  FormControlState<T> get state => _createStateFrom(source);

  @override
  void Function() listen(void Function(FormControlState<T> state) listener) {
    void onChanges(_) => listener(_createStateFrom(source));

    final subscriptions = [
      source.statusChanged.listen(onChanges),
      source.valueChanges.listen(onChanges),
      source.touchChanges.listen(onChanges),
    ];
    return () {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    };
  }

  FormControlState<T> _createStateFrom(AbstractControl control) {
    return FormControlState(
      value: control.value,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
    );
  }
}

class _FormGroupStateProvider extends SourceProviderListenable<FormGroup, FormGroupState> {
  _FormGroupStateProvider(super.source);

  @override
  FormGroupState get state => _createStateFrom(source);

  @override
  void Function() listen(void Function(FormGroupState state) listener) {
    void onChanges(_) => listener(_createStateFrom(source));

    final subscriptions = [
      source.statusChanged.listen(onChanges),
      source.valueChanges.listen(onChanges),
      source.touchChanges.listen(onChanges),
      source.collectionChanges.listen(onChanges),
    ];
    return () {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    };
  }

  FormGroupState _createStateFrom(FormGroup control) {
    return FormGroupState(
      value: control.value,
      touched: control.touched,
      errors: control.errors,
      status: control.status,
      controls: control.controls,
    );
  }
}
