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

  void markAsReset({
    bool updateParent = true,
    bool removeFocus = false,
    bool? disabled,
  }) {
    markAsPristine(updateParent: updateParent);
    markAsUntouched(updateParent: updateParent);
    if (disabled != null) (disabled ? markAsDisabled : markAsEnabled)(emitEvent: false);
    if (removeFocus) unfocus(touched: false);
  }

  @Deprecated('In favour of markAsReset')
  void markAsClean({bool? disabled}) => markAsReset(disabled: disabled);

  void markAs({
    bool? disabled,
    bool? pristine,
    bool? touched,
    bool? allTouched,
    bool? focus,
  }) {
    if (pristine != null) (pristine ? markAsPristine : markAsDirty)();
    if (touched != null) (touched ? markAsTouched : markAsUntouched)();
    if (disabled != null) (disabled ? markAsDisabled : markAsEnabled)();
    if (focus != null) (focus ? this.focus : unfocus)();
  }
}

extension FormArrayExtensions<T> on FormArray<T> {
  void tryAddAll(Iterable<AbstractControl<T>> controls) {
    controls.forEach(tryAdd);
  }

  void tryAdd(AbstractControl<T> control) {
    final hasControl = controls.contains(control);
    if (!hasControl) add(control);
  }

  void tryRemoveAll(Iterable<AbstractControl<T>> controls) {
    controls.forEach(tryRemove);
  }

  void tryRemove(AbstractControl<T> control) {
    final index = controls.indexOf(control);
    if (index >= 0) removeAt(index);
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
    Future<void> Function(T arg) submit, {
    bool keepDisabled = false,
  }) {
    return (arg) async {
      switch (status) {
        case ControlStatus.disabled:
          return;
        case ControlStatus.pending:
          return;
        case ControlStatus.invalid:
          markAllAsTouched();
        case ControlStatus.valid:
          try {
            markAsDisabled();

            await submit(arg);

            if (keepDisabled) return;
            markAsEnabled();
          } catch (_) {
            markAsEnabled();
            rethrow;
          }
      }
    };
  }

  void Function() handleVoidSubmit<T>(
    Future<void> Function() submit, {
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
