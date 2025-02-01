import 'package:flutter/foundation.dart';

extension ListenChangesListenableExtension on Listenable {
  void Function() listenChanges(void Function() listener) {
    addListener(listener);
    return () => removeListener(listener);
  }
}

extension ListenValueListenableExtension<T> on ValueListenable<T> {
  void Function() listenValue(void Function(T value) listener) {
    void onChange() => listener(value);
    addListener(onChange);
    return () => removeListener(onChange);
  }
}
