import 'package:flutter/widgets.dart';

class SharedAppValue<T> {
  final SharedAppDataInitCallback<T> _init;

  SharedAppValue(this._init);

  static SharedAppValueFamily<V> family<V>(SharedAppDataInitCallback<V> init) =>
      SharedAppValueFamily(init);

  Object get _key => this;

  T get(BuildContext context) => SharedAppData.getValue(context, _key, _init);

  void set(BuildContext context, T value) => SharedAppData.setValue(context, _key, value);
}

class SharedAppValueFamily<V> {
  final SharedAppDataInitCallback<V> _init;

  SharedAppValueFamily(this._init);

  SharedAppValue<V> call(String argument) => _SharedAppValueFamily(this, argument);
}

class _SharedAppValueFamily<T, A> extends SharedAppValue<T> {
  final SharedAppValueFamily<T> _origin;
  final A _argument;

  _SharedAppValueFamily(this._origin, this._argument) : super(_origin._init);

  @override
  Object get _key => (_origin, _argument);
}
