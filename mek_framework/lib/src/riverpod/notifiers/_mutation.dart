import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotifierDelegate<T> {
  var _isDisposed = false;
  final StateNotifier<T> _notifier;

  NotifierDelegate(this._notifier);

  T get state {
    _ensureIsMounted();
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    return _notifier.state;
  }

  set state(T state) {
    _ensureIsMounted();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    _notifier.state = state;
  }

  void _ensureIsMounted() {
    if (!_isDisposed) return;
    throw StateError('''
Tried to use $runtimeType after `dispose` was called.

Consider checking `mounted`.
''');
  }

  void dispose() {
    _isDisposed = false;
  }
}
