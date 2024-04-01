import 'dart:async';

import 'package:collection/collection.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:meta/meta.dart';

abstract class GroupFieldBlocState<TValue> extends FieldBlocStateBase<TValue> {
  @internal
  Iterable<FieldBlocBase<FieldBlocStateBase<dynamic>, dynamic>> get flatFieldBlocs;
  @internal
  Iterable<FieldBlocStateBase<dynamic>> get flatFieldStates;

  @override
  late final bool isEnabled = flatFieldStates.any((e) => e.isEnabled);
  @override
  late final bool isValidating = flatFieldStates.any((e) => e.isValidating);
  @override
  late final bool isDirty = flatFieldStates.any((e) => e.isDirty);
  @override
  late final bool hasUpdatedValue = flatFieldStates.every((e) => e.hasUpdatedValue);
  @override
  late final bool hasInitialValue = flatFieldStates.every((e) => e.hasInitialValue);
  @override
  late final Object? error = flatFieldStates.firstWhereOrNull((e) => e.error != null)?.error;

  GroupFieldBlocState<TValue> rebuild();
}

abstract class GroupFieldBloc<TState extends GroupFieldBlocState<TValue>, TValue>
    extends FieldBlocBase<TState, TValue> {
  StreamSubscription<void>? _fieldBlocsSub;

  GroupFieldBloc(TState state) : super(state) {
    onAttachingListeners(state);
  }

  @override
  void markStateAs({bool? enabled, bool? touched}) {
    if (enabled == null && touched == null) return;
    onChildrenUpdating(() {
      for (final field in state.flatFieldBlocs) {
        field.markStateAs(enabled: enabled, touched: touched);
      }
      emit(state.rebuild() as TState);
    });
  }

  @override
  void clear({bool shouldUpdate = true}) {
    onChildrenUpdating(() {
      for (final field in state.flatFieldBlocs) {
        field.clear(shouldUpdate: shouldUpdate);
      }
      emit(state.rebuild() as TState);
    });
  }

  @override
  FutureOr<bool> validate() {
    return onChildrenUpdating(() {
      var isValid = true;
      final pending = <Future<bool>>[];
      for (final fieldBloc in state.flatFieldBlocs) {
        final result = fieldBloc.validate();
        if (result is bool) {
          isValid = isValid && result;
        } else {
          pending.add(result);
        }
      }

      emit(state.rebuild() as TState);

      if (pending.isEmpty) {
        return isValid;
      } else {
        return Future.wait(pending.followedBy([Future.value(isValid)]))
            .then((value) => value.every((e) => e));
      }
    });
  }

  @override
  Future<void> close() async {
    await _fieldBlocsSub?.cancel();
    await Future.wait(state.flatFieldBlocs.map((e) => e.close()));
    return super.close();
  }

  @protected
  R onChildrenUpdating<R>(R Function() fn) {
    unawaited(_fieldBlocsSub?.cancel());
    final result = fn();
    _fieldBlocsSub = onAttachingListeners(state);
    return result;
  }

  @protected
  StreamSubscription<void> onAttachingListeners(TState state);
}
