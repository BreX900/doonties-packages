part of '../source.dart';

extension SourceFormControlExtraExtensions
    on AbstractControlSource<AbstractControl<Object?>, Object?> {
  SourceListenable<bool> get isValueInitial => value.selectWith(control, _isValueInitial);
  SourceListenable<MapEntry<String, Object>?> get error => errors.select(_error);

  static bool _isValueInitial<T extends Object>(AbstractControl control, T? value) {
    return switch (control) {
      FormControlTyped() => control.initialValue == value,
      FormArray() => control.controls.every((control) => _isValueInitial(control, control.value)),
      FormGroup() => control.controls.values.every((control) {
        return _isValueInitial(control, control.value);
      }),
      _ => true,
    };
  }

  static MapEntry<String, Object>? _error(Map<String, Object> errors) => errors.entries.firstOrNull;
}

// ==========================    CUSTOM FORM CONTROLS      ============================

extension SourceFormListExtraExtensions<C extends AbstractControl<T>, T>
    on AbstractControlSource<FormList<C, T>, List<T?>> {
  SourceListenable<List<C>> get controlsTyped => controls.select(_typeControls);

  static List<C> _typeControls<C extends AbstractControl<Object?>>(
    List<AbstractControl<Object?>> controls,
  ) => controls as List<C>;
}

extension SourceFormMapExtraExtensions<C extends AbstractControl<T>, T>
    on AbstractControlSource<FormMap<C, T>, Map<String, Object?>> {
  SourceListenable<Map<String, T?>> get valueTyped => value.select(_typeValue);
  SourceListenable<Map<String, C>> get controlsTyped => controls.select(_typeControls);

  static Map<String, T?> _typeValue<T>(Map<String, Object?>? value) =>
      value as Map<String, T?>? ?? const {};
  static Map<String, C> _typeControls<C>(Map<String, AbstractControl<Object?>> controls) =>
      controls as Map<String, C>;
}
