import 'dart:async';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:rxdart/rxdart.dart';

extension ControlStatusExtensions on ControlStatus {
  bool get isPending => this == ControlStatus.pending;
  bool get isValid => this == ControlStatus.valid;
  bool get isInvalid => this == ControlStatus.invalid;
  bool get isDisabled => this == ControlStatus.disabled;
}

extension AbstractControlExtensions<T> on AbstractControl<T> {
  Stream<T?> get valueHotChanges => valueChanges.startWith(value);

  void markAsClean({bool? enabled}) {
    markAsPristine();
    markAsUntouched();
    if (enabled != null) (enabled ? markAsEnabled : markAsDisabled)();
  }

  void markAs({bool? enabled, bool? pristine, bool? touched, bool? allTouched}) {
    if (enabled != null) (enabled ? markAsEnabled : markAsDisabled)();
    if (pristine != null) (pristine ? markAsPristine : markAsDirty)();
    if (touched != null) (touched ? markAsTouched : markAsUntouched)();
  }
}

extension FormArrayExtensions<T> on FormArray<T> {
  void tryAddAll(Iterable<FormControl<T>> controls) {
    for (final control in controls) {
      final hasControl = this.controls.contains(control);
      if (hasControl) continue;
      add(control);
    }
  }

  void tryRemoveAll(Iterable<FormControl<T>> controls) {
    for (final control in controls) {
      final index = this.controls.indexOf(control);
      if (index == -1) continue;
      removeAt(index);
    }
  }
}

extension ReactiveFormConfigExtensions on ReactiveFormConfig? {
  String? maybeBuildErrorText(
    MapEntry<String, dynamic>? error, [
    Map<String, ValidationMessageFunction>? validationMessages,
  ]) {
    return error != null ? buildErrorText(error, validationMessages) : null;
  }

  String buildErrorText(
    MapEntry<String, dynamic> error, [
    Map<String, ValidationMessageFunction>? validationMessages,
  ]) {
    if (validationMessages != null) {
      final validationMessage = validationMessages[error.key];
      if (validationMessage != null) return validationMessage(error.value);
    }

    final validationMessage = this?.validationMessages[error.key];
    return validationMessage?.call(error.value) ?? error.key;
  }
}

extension HandleSubmitAbstractControlExtension on AbstractControl<Object?> {
  void Function(T arg) handleSubmit<T>(
    FutureOr<void> Function(T arg) submit, {
    bool keepDisabled = false,
  }) {
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

          if (keepDisabled) return;
          unawaited(result.whenComplete(markAsEnabled));
      }
    };
  }

  void Function() handleVoidSubmit<T>(
    FutureOr<void> Function() submit, {
    bool shouldKeepDisabled = false,
  }) {
    // ignore: discarded_futures
    return () => handleSubmit((_) => submit())(null);
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
      addAll([control], updateParent: updateParent, emitEvent: emitEvent);

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
