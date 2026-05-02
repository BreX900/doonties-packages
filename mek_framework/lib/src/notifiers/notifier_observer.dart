import 'dart:async';

import 'package:flutter/material.dart';

class NotifierObserver {
  static NotifierObserver current = const NotifierObserver();

  const NotifierObserver();

  void onUncaughtError(ChangeNotifier notifier, Object error, StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }
}
