import 'package:flutter/widgets.dart';

class SharedAppValue<V> {
  final (SharedAppValueFamily<V>, String)? _key;
  final SharedAppDataInitCallback<V> _init;

  const SharedAppValue(this._init) : _key = null;

  const SharedAppValue._(this._key, this._init);

  static SharedAppValueFamily<V> family<V>(SharedAppDataInitCallback<V> init) =>
      SharedAppValueFamily(init);

  V get(BuildContext context) => SharedAppData.getValue(context, _key ?? this, _init);

  void set(BuildContext context, V value) => SharedAppData.setValue(context, _key ?? this, value);
}

class SharedAppValueFamily<V> {
  final SharedAppDataInitCallback<V> _init;

  SharedAppValueFamily(this._init);

  SharedAppValue<V> call(String argument) => SharedAppValue._((this, argument), _init);
}
