import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/reactive_forms/reactive_forms.dart';
// ignore: implementation_imports
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:reactive_forms/reactive_forms.dart';

class _AbstractControlProviders<T> {
  final AbstractControl<T> _control;

  _AbstractControlProviders(this._control);

  @Deprecated('In favour of [AbstractControl.provider.value]')
  ProviderListenable<T?> get valueProvider => _AbstractControlValueProvider(_control);

  @Deprecated('In favour of [AbstractControl.provider.status]')
  ProviderListenable<ControlStatus> get statusProvider => _AbstractControlStatusProvider(_control);

  @Deprecated('In favour of [AbstractControl.provider.status]')
  ProviderListenable<bool> get statusIsDisabled => statusProvider.select(_isDisabled);

  static bool _isDisabled(ControlStatus status) => status == ControlStatus.disabled;
}

extension AbstractControlProviders<T> on AbstractControl<T> {
  @Deprecated('In favour of [AbstractControl.provider]')
  // ignore: library_private_types_in_public_api
  _AbstractControlProviders get providers => _AbstractControlProviders(this);

  @Deprecated('In favour of [AbstractControl.provider.value]')
  ProviderListenable<T?> get valueProvider => _AbstractControlValueProvider(this);

  @Deprecated('In favour of [AbstractControl.provider.status]')
  ProviderListenable<ControlStatus> get statusProvider => _AbstractControlStatusProvider(this);
}

extension FormArrayProviders<T> on FormArray<T> {
  @Deprecated('In favour of [AbstractControl.provider.controls]')
  ProviderListenable<List<AbstractControl<T>>> get controlsProvider =>
      _FormArrayControlsProvider(this);
}

extension FormListProviders<C extends AbstractControl<V>, V> on FormList<C, V> {
  @Deprecated('In favour of [AbstractControl.provider.controls]')
  ProviderListenable<List<C>> get controlsProvider => _FormListControlsProvider(this);
}

class _AbstractControlValueProvider<T> extends SourceProviderListenable<AbstractControl<T>, T?> {
  _AbstractControlValueProvider(super.source);

  @override
  T? get state => source.value;

  @override
  void Function() listen(void Function(T? value) listener) {
    return source.valueChanges.listen((value) => listener(value)).cancel;
  }
}

class _AbstractControlStatusProvider
    extends SourceProviderListenable<AbstractControl<Object?>, ControlStatus> {
  _AbstractControlStatusProvider(super.source);

  @override
  ControlStatus get state => source.status;

  @override
  void Function() listen(void Function(ControlStatus value) listener) {
    return source.statusChanged.listen(listener).cancel;
  }
}

class _FormArrayControlsProvider<T>
    extends SourceProviderListenable<FormArray<T>, List<AbstractControl<T>>> {
  _FormArrayControlsProvider(super.source);

  @override
  List<AbstractControl<T>> get state => source.controls;

  @override
  void Function() listen(void Function(List<AbstractControl<T>> controls) listener) {
    return source.collectionChanges.listen((controls) => listener(controls.cast())).cancel;
  }
}

class _FormListControlsProvider<C extends AbstractControl<V>, V>
    extends SourceProviderListenable<FormList<C, V>, List<C>> {
  _FormListControlsProvider(super.source);

  @override
  List<C> get state => source.controls;

  @override
  void Function() listen(void Function(List<C> controls) listener) {
    return source.collectionChanges.listen(listener).cancel;
  }
}
