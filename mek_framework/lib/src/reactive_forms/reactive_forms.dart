import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class FormList<C extends AbstractControl<V>, V> extends FormArray<V> {
  FormList(
    List<C> super.controls, {
    super.validators,
    super.asyncValidators,
    super.asyncValidatorsDebounceTime,
    super.disabled,
  });

  @override
  late final Stream<List<C>> collectionChanges = super.collectionChanges.map((e) => e.cast());

  @override
  List<C> get controls => super.controls.cast<C>();

  @override
  void insert(int index, covariant C control, {bool updateParent = true, bool emitEvent = true}) =>
      super.insert(index, control, updateParent: updateParent, emitEvent: emitEvent);

  @override
  void add(covariant C control, {bool updateParent = true, bool emitEvent = true}) =>
      super.add(control, updateParent: updateParent, emitEvent: emitEvent);

  @override
  void addAll(covariant List<C> controls, {bool updateParent = true, bool emitEvent = true}) =>
      super.addAll(controls, updateParent: updateParent, emitEvent: emitEvent);

  @override
  C removeAt(int index, {bool emitEvent = true, bool updateParent = true}) =>
      super.removeAt(index, emitEvent: emitEvent, updateParent: updateParent) as C;

  @override
  void remove(covariant C control, {bool emitEvent = true, bool updateParent = true}) =>
      super.remove(control, emitEvent: emitEvent, updateParent: updateParent);

  @override
  C control(String name) => super.control(name) as C;

  @override
  C? findControl(String path) => super.findControl(path) as C?;
}

class FormMap<C extends AbstractControl<V>, V> extends FormGroup {
  FormMap(
    Map<String, C> super.controls, {
    super.validators,
    super.asyncValidators,
    super.asyncValidatorsDebounceTime,
    super.disabled,
  });

  @override
  Map<String, V?> get value => super.value.cast();

  @override
  set value(covariant Map<String, V?>? value) => super.value = value;

  @override
  void updateValue(covariant Map<String, V?>? value,
          {bool updateParent = true, bool emitEvent = true}) =>
      super.updateValue(value, updateParent: updateParent, emitEvent: emitEvent);

  @override
  void patchValue(covariant Map<String, V?>? value,
          {bool updateParent = true, bool emitEvent = true}) =>
      super.patchValue(value, updateParent: updateParent, emitEvent: emitEvent);

  @override
  late final Stream<List<C>> collectionChanges = super.collectionChanges.map((e) => e.cast());

  @override
  Map<String, C> get controls => super.controls.cast();

  @override
  void addAll(covariant Map<String, C> controls) => super.addAll(controls);

  @override
  C control(String name) => super.control(name) as C;

  @override
  C? findControl(String path) => super.findControl(path) as C?;
}

extension ProviderListenableControlStatusExtensions on ProviderListenable<ControlStatus> {
  ProviderListenable<bool> get isEnabled => select(_isEnabled);

  static bool _isEnabled(ControlStatus status) => status != ControlStatus.disabled;
}
