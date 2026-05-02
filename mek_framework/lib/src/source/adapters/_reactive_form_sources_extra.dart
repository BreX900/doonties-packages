import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:mek/src/reactive_forms/controls/form_control_typed.dart';
import 'package:mek/src/reactive_forms/reactive_forms.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension FormControlExtraProviderExtensions on ProviderListenable<AbstractControl<Object?>> {
  ProviderListenable<bool> get isValueInitial => select(_isValueInitial);

  ProviderListenable<MapEntry<String, Object?>?> get error => select(_error);

  static bool _isValueInitial<T extends Object>(AbstractControl control) {
    return switch (control) {
      FormControlTyped() => control.initialValue == control.value,
      FormArray() => control.controls.every(_isValueInitial),
      FormGroup() => control.controls.values.every(_isValueInitial),
      _ => true,
    };
  }

  static MapEntry<String, Object?>? _error(AbstractControl control) =>
      control.errors.entries.firstOrNull;
}

// ==========================    CUSTOM FORM CONTROLS      ============================

extension FormListExtraProviderExtensions<C extends AbstractControl<T>, T>
    on ProviderListenable<FormList<C, T>> {
  ProviderListenable<List<C>> get controlsTyped => select(_typeControls);

  List<C> _typeControls(FormList<C, T> control) => control.controls;
}

extension FormMapExtraProviderExtensions<C extends AbstractControl<T>, T>
    on ProviderListenable<FormMap<C, T>> {
  ProviderListenable<Map<String, T?>> get valueTyped => select(_typeValue);

  ProviderListenable<Map<String, C>> get controlsTyped => select(_typeControls);

  Map<String, T?> _typeValue(FormMap<C, T> control) => control.value;

  Map<String, C> _typeControls(FormMap<C, T> control) => control.controls;
}
