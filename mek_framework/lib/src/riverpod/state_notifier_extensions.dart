// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';

extension StateNotifierExtensions<TState> on StateNotifier<TState> {
  void emit(TState state) {
    try {
      this.state = state;
    } catch (error, stackTrace) {
      lg.severe('Error on state notifier listeners $this', error, stackTrace);
    }
  }

  void addError(Object error, StackTrace stackTrace) {
    lg.severe('Error on state notifier $this', error, stackTrace);
  }
}
