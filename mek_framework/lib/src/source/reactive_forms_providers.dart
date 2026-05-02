// Version: 4.0.0

import 'package:reactive_forms/reactive_forms.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:riverpod/src/internals.dart';

// ignore: invalid_use_of_internal_member
final _family = NotifierProviderFamily.internal((_) => throw UnimplementedError());

extension AbstractControlProviderExtension<T extends AbstractControl> on T {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _AbstractControlNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _AbstractControlNotifier<T extends AbstractControl> extends Notifier<T> {
  final T control;

  _AbstractControlNotifier(this.control);

  @override
  T build() {
    final statusSubscription = control.statusChanged.listen((_) => ref.notifyListeners());
    ref.onDispose(statusSubscription.cancel);
    final valueSubscription = control.valueChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(valueSubscription.cancel);
    final touchSubscription = control.touchChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(touchSubscription.cancel);
    return control;
  }
}

extension ProviderAbstractControlExtensions<T extends AbstractControl<V>, V>
    on ProviderListenable<T> {
  ProviderListenable<ControlStatus> get status => select((control) => control.status);

  ProviderListenable<bool> get pristine => select((control) => control.pristine);

  ProviderListenable<bool> get dirty => select((control) => control.dirty);

  ProviderListenable<Map<String, Object>> get errors => select((control) => control.errors.cast());

  ProviderListenable<bool> get hasErrors => select((control) => control.hasErrors);

  ProviderListenable<V?> get value => select((control) => control.value);

  ProviderListenable<bool> get isEmpty => select(_isEmpty);

  ProviderListenable<bool> get touched => select((control) => control.touched);

  static bool _isEmpty(Object? value) => switch (value) {
    null => true,
    String() => value.isEmpty,
    Iterable() => value.isEmpty,
    Map() => value.isEmpty,
    _ => false,
  };
}

extension FormControlCollectionProviderExtension<T extends FormControlCollection> on T {
  ProviderListenable<T> get provider =>
      // ignore: invalid_use_of_internal_member
      NotifierProvider.internal(
        () => _FormControlCollectionNotifier(this),
        name: '$this',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
        retry: (_, _) => null,
        from: _family,
        argument: this,
      );
}

class _FormControlCollectionNotifier<T extends FormControlCollection> extends Notifier<T> {
  final T control;

  _FormControlCollectionNotifier(this.control);

  @override
  T build() {
    final statusSubscription = control.statusChanged.listen((_) => ref.notifyListeners());
    ref.onDispose(statusSubscription.cancel);
    final valueSubscription = control.valueChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(valueSubscription.cancel);
    final touchSubscription = control.touchChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(touchSubscription.cancel);
    final collectionSubscription = control.collectionChanges.listen((_) => ref.notifyListeners());
    ref.onDispose(collectionSubscription.cancel);
    return control;
  }
}

extension ProviderFormGroupExtensions on ProviderListenable<FormGroup> {
  ProviderListenable<Map<String, AbstractControl<Object?>>> get controls =>
      select((control) => control.controls);
}

extension ProviderFormArrayExtensions<T> on ProviderListenable<FormArray<T>> {
  ProviderListenable<List<AbstractControl<T>>> get controls =>
      select((control) => control.controls);
}

extension ProviderControlStatusExtensions on ProviderListenable<ControlStatus> {
  ProviderListenable<bool> get pending => select(_pending);

  ProviderListenable<bool> get valid => select(_valid);

  ProviderListenable<bool> get invalid => select(_invalid);

  ProviderListenable<bool> get disabled => select(_disabled);

  ProviderListenable<bool> get enabled => select(_enabled);

  static bool _pending(ControlStatus status) => status == ControlStatus.pending;

  static bool _valid(ControlStatus status) => status == ControlStatus.valid;

  static bool _invalid(ControlStatus status) => status == ControlStatus.invalid;

  static bool _disabled(ControlStatus status) => status == ControlStatus.disabled;

  static bool _enabled(ControlStatus status) => !_disabled(status);
}
