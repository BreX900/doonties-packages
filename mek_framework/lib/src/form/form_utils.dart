import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';

extension ListFieldBlocBaseExtensions<T> on FieldBlocRule<IList<T>> {
  void changeAddingValue(T value) => changeValue(state.value.add(value));

  void changeRemovingValue(T value) => changeValue(state.value.remove(value));

  // ignore: avoid_positional_boolean_parameters
  void changeTogglingValue(bool? isSelected, T value) {
    if (isSelected ?? false) {
      changeAddingValue(value);
    } else {
      changeRemovingValue(value);
    }
  }
}
