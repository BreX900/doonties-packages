import 'package:bloc/bloc.dart';

class StateBloc<T> extends Cubit<T> {
  StateBloc(super.initialState);

  @override
  void emit(T state) => super.emit(state);

  StateStreamable<T> asStreamable() => this;
}
