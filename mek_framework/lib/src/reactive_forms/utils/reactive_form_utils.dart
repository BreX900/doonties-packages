import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:reactive_forms/reactive_forms.dart';

extension DidToggleListReactiveFormFieldStateExtension<T>
    on ReactiveFormFieldState<dynamic, IList<T>> {
  // ignore: avoid_positional_boolean_parameters
  void didToggle(bool? isAdding, T value) {
    final values = this.value ?? IList<T>.empty();
    didChange((isAdding ?? false) ? values.add(value) : values.remove(value));
  }
}

extension DidToggleSetReactiveFormFieldStateExtension<T>
    on ReactiveFormFieldState<dynamic, ISet<T>> {
  // ignore: avoid_positional_boolean_parameters
  void didToggle(bool? isAdding, T value) {
    final values = this.value ?? ISet<T>.empty();
    didChange((isAdding ?? false) ? values.add(value) : values.remove(value));
  }
}
