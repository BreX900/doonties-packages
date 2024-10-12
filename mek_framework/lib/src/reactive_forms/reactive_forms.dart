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
  List<C> get controls => super.controls.cast<C>();

  @override
  late final Stream<List<C>> collectionChanges = super.collectionChanges.map((e) => e.cast());

  @override
  C removeAt(int index, {bool emitEvent = true, bool updateParent = true}) =>
      super.removeAt(index, emitEvent: emitEvent, updateParent: updateParent) as C;
}

class FormMulti<C extends AbstractControl<V>, V> extends FormGroup {
  FormMulti(
    Map<String, C> super.controls, {
    super.validators,
    super.asyncValidators,
    super.asyncValidatorsDebounceTime,
    super.disabled,
  });

  @override
  Map<String, V?> get value => super.value.cast();

  @override
  C control(String name) => super.control(name) as C;

  @override
  Map<String, C> get controls => super.controls.cast();

  @override
  late final Stream<List<C>> collectionChanges = super.collectionChanges.map((e) => e.cast());

  @override
  void addAll(covariant Map<String, C> controls) => super.addAll(controls);
}

extension ProviderListenableControlStatusExtensions on ProviderListenable<ControlStatus> {
  ProviderListenable<bool> get isEnabled => select(_isEnabled);

  static bool _isEnabled(ControlStatus status) => status != ControlStatus.disabled;
}
