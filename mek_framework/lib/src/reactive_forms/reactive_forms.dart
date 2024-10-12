import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension ReactiveFormConfigExtensions on ReactiveFormConfig? {
  String? buildErrorText(
    MapEntry<String, dynamic>? error, [
    Map<String, ValidationMessageFunction>? validationMessages,
  ]) {
    if (error == null) return null;

    if (validationMessages != null) {
      final validationMessage = validationMessages[error.key];
      if (validationMessage != null) return validationMessage(error.value);
    }

    final validationMessage = this?.validationMessages[error.key];
    return validationMessage?.call(error.value) ?? error.key;
  }
}

extension HandleSubmitAbstractControlExtension on AbstractControl<Object?> {
  void Function(T arg) handleSubmit<T>(FutureOr<void> Function(T arg) submit) {
    return (arg) {
      switch (status) {
        case ControlStatus.disabled:
          return;
        case ControlStatus.pending:
          return;
        case ControlStatus.invalid:
          markAllAsTouched();
        case ControlStatus.valid:
          // ignore: discarded_futures
          final result = submit(arg);
          if (result is! Future<void>) return;

          markAsDisabled();

          unawaited(result.whenComplete(markAsEnabled));
      }
    };
  }
}

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

extension ProviderListenableControlStatusExtensions on ProviderListenable<ControlStatus> {
  ProviderListenable<bool> get isEnabled => select(_isEnabled);

  static bool _isEnabled(ControlStatus status) => status != ControlStatus.disabled;
}

extension FormArrayProviders<T> on FormArray<T> {
  ProviderListenable<List<AbstractControl<T>>> get controlsProvider =>
      _FormArrayControlsProvider(this);
}

extension FormListProviders<C extends AbstractControl<V>, V> on FormList<C, V> {
  ProviderListenable<List<C>> get controlsProvider => _FormListControlsProvider(this);
}

class FormList<C extends AbstractControl<V>, V> extends FormArray<V> {
  FormList(List<C> super.controls);

  @override
  List<C> get controls => super.controls.cast<C>();

  @override
  late final Stream<List<C>> collectionChanges = super.collectionChanges.map((e) => e.cast());

  @override
  C removeAt(int index, {bool emitEvent = true, bool updateParent = true}) =>
      super.removeAt(index, emitEvent: emitEvent, updateParent: updateParent) as C;
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
