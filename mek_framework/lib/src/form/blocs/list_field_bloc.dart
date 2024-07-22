import 'dart:async';

import 'package:collection/collection.dart';
import 'package:mek/src/bloc/bloc_extensions.dart';
import 'package:mek/src/form/blocs/_group_field_bloc.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'list_field_bloc.g.dart';

@DataClass(changeable: true)
class ListFieldBlocState<TFieldBloc extends FieldBlocRule<TValue>, TValue>
    extends GroupFieldBlocState<List<TValue>> with _$ListFieldBlocState<TFieldBloc, TValue> {
  final List<TFieldBloc> fieldBlocs;
  final List<FieldBlocStateBase<TValue>> fieldStates;

  ListFieldBlocState({
    required this.fieldBlocs,
    required this.fieldStates,
  });

  @override
  late final List<TValue> value = fieldStates.map((e) => e.value).toList();

  @override
  Iterable<FieldBlocBase<FieldBlocStateBase<TValue>, TValue>> get flatFieldBlocs => fieldBlocs;

  @override
  Iterable<FieldBlocStateBase<TValue>> get flatFieldStates => fieldStates;

  @override
  ListFieldBlocState<TFieldBloc, TValue> rebuild() {
    return change((c) => c.fieldStates = fieldBlocs.map((e) => e.state).toList());
  }
}

typedef ListFieldBloc<TValue> = ListFieldsBloc<FieldBlocRule<TValue>, TValue>;

class ListFieldsBloc<TFieldBloc extends FieldBlocRule<TValue>, TValue>
    extends GroupFieldBloc<ListFieldBlocState<TFieldBloc, TValue>, List<TValue>> {
  ListFieldsBloc({
    List<TFieldBloc> fieldBlocs = const [],
  }) : super(ListFieldBlocState(
          fieldBlocs: fieldBlocs,
          fieldStates: fieldBlocs.map((e) => e.state).toList(),
        ));

  void addFieldBlocs(Iterable<TFieldBloc> fieldBlocs) {
    updateFieldBlocs([...state.fieldBlocs, ...fieldBlocs]);
  }

  void removeFieldBlocs(Iterable<TFieldBloc> fieldBlocs) {
    updateFieldBlocs(state.fieldBlocs.whereNot(fieldBlocs.contains));
  }

  void updateFieldBlocs(Iterable<TFieldBloc> fieldBlocs) {
    onChildrenUpdating(() {
      emit(state.change((c) => c
        ..fieldBlocs = [...fieldBlocs]
        ..fieldStates = fieldBlocs.map((e) => e.state).toList()));
    });
  }

  @override
  void changeValue(List<TValue> value) {
    _ensureValidValue(value);

    onChildrenUpdating(() {
      for (var i = 0; i < state.fieldBlocs.length; i++) {
        state.fieldBlocs[i].changeValue(value[i]);
      }
      emit(state.rebuild());
    });
  }

  @override
  void updateInitialValue(List<TValue> value) {
    _ensureValidValue(value);

    onChildrenUpdating(() {
      for (var i = 0; i < state.fieldBlocs.length; i++) {
        state.fieldBlocs[i].updateInitialValue(value[i]);
      }
      emit(state.rebuild());
    });
  }

  @override
  void updateValue(List<TValue> value) {
    _ensureValidValue(value);

    onChildrenUpdating(() {
      for (var i = 0; i < state.fieldBlocs.length; i++) {
        state.fieldBlocs[i].updateValue(value[i]);
      }
      emit(state.rebuild());
    });
  }

  @override
  @protected
  StreamSubscription<void> onAttachingListeners(ListFieldBlocState<TFieldBloc, TValue> state) {
    return Rx.combineLatestList(state.fieldBlocs.map((e) => e.hotStream))
        .skip(1)
        .listen((states) => emit(this.state.change((c) => c..fieldStates = states)));
  }

  void _ensureValidValue(List<TValue> value) {
    if (state.fieldBlocs.length != value.length) {
      throw StateError('Invalid value length.\n'
          'Field blocs length: ${state.fieldBlocs.length}\n'
          'Value length: ${value.length}');
    }
  }
}
