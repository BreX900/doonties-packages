import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: implementation_imports
import 'package:mek/src/riverpod/adapters/_state_provider_listenable.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension AbstractControlProviders<T> on AbstractControl<T> {
  ProviderListenable<T?> get valueProvider => _AbstractControlValueProvider(this);
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
  T? get state => source.value!;

  @override
  void Function() listen(void Function(T? value) listener) {
    return source.valueChanges.listen((value) => listener(value)).cancel;
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
