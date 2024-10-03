import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/src/bloc/bloc_extensions.dart';
import 'package:mek/src/form/blocs/_group_field_bloc.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:mekart/mekart.dart';
import 'package:rxdart/rxdart.dart';

part 'map_field_bloc.g.dart';

@DataClass(changeable: true)
class MapFieldBlocState<TKey, TValue> extends GroupFieldBlocState<IMap<TKey, TValue>>
    with _$MapFieldBlocState<TKey, TValue> {
  final IMap<TKey, FieldBlocRule<TValue>> fieldBlocs;
  final IMap<TKey, FieldBlocStateBase<TValue>> fieldStates;

  MapFieldBlocState({
    required this.fieldBlocs,
    required this.fieldStates,
  });

  @override
  late final IMap<TKey, TValue> value = fieldStates.map((key, state) => MapEntry(key, state.value));

  @override
  Iterable<FieldBlocBase<FieldBlocStateBase<TValue>, TValue>> get flatFieldBlocs =>
      fieldBlocs.values;

  @override
  Iterable<FieldBlocStateBase<TValue>> get flatFieldStates => fieldStates.values;

  @override
  MapFieldBlocState<TKey, TValue> rebuild() {
    return change((c) => c
      ..fieldStates = fieldBlocs.map((key, fieldBloc) {
        return MapEntry(key, fieldBloc.state);
      }));
  }
}

class MapFieldBloc<TKey, TValue>
    extends GroupFieldBloc<MapFieldBlocState<TKey, TValue>, IMap<TKey, TValue>> {
  MapFieldBloc()
      : super(MapFieldBlocState(
          fieldBlocs: const IMapConst({}),
          fieldStates: const IMapConst({}),
        ));

  void addFieldBlocs(IMap<TKey, FieldBlocRule<TValue>> fieldBlocs) {
    updateFieldBlocs(state.fieldBlocs.addAll(fieldBlocs));
  }

  void updateFieldBlocs(IMap<TKey, FieldBlocRule<TValue>> fieldBlocs) {
    onChildrenUpdating(() {
      emit(state.change((c) => c
        ..fieldBlocs = fieldBlocs
        ..fieldStates = fieldBlocs.map((key, fieldBloc) => MapEntry(key, fieldBloc.state))));
    });
  }

  @override
  void changeValue(IMap<TKey, TValue> value) {
    // _ensureValidValue(value);

    onChildrenUpdating(() {
      for (final key in value.keys) {
        state.fieldBlocs[key]!.changeValue(value[key] as TValue);
      }
      emit(state.rebuild());
    });
  }

  @override
  void updateInitialValue(IMap<TKey, TValue> value) {
    // _ensureValidValue(value);

    onChildrenUpdating(() {
      for (final key in value.keys) {
        state.fieldBlocs[key]!.updateInitialValue(value[key] as TValue);
      }
      emit(state.rebuild());
    });
  }

  @override
  void updateValue(IMap<TKey, TValue> value) {
    // _ensureValidValue(value);

    onChildrenUpdating(() {
      for (final key in value.keys) {
        state.fieldBlocs[key]!.updateValue(value[key] as TValue);
      }
      emit(state.rebuild());
    });
  }

  @override
  StreamSubscription<void> onAttachingListeners(MapFieldBlocState<TKey, TValue> state) {
    return Rx.combineLatest(state.fieldBlocs.entries.mapTo((key, fieldBloc) {
      return fieldBloc.hotStream.map((state) => MapEntry(key, state));
      // ignore: unnecessary_lambdas
    }), (states) => IMap.fromEntries(states)).skip(1).listen((states) {
      emit(this.state.change((c) => c..fieldStates = states));
    });
  }

  // ignore: unused_element
  void _ensureValidValue(Map<TKey, TValue> value) {
    final invalidKeys = value.keys.whereNot(state.fieldBlocs.containsKey).toList();

    if (invalidKeys.isNotEmpty) {
      throw StateError('Invalid value keys.\n'
          'Field blocs keys: ${state.fieldBlocs.keys.join(',')}\n'
          'Invalid keys: ${invalidKeys.join(',')}');
    }
  }
}
