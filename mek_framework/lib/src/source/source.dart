import 'dart:async';

import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:flutter_riverpod/src/internals.dart';
import 'package:mek/mek.dart';
import 'package:reactive_forms/reactive_forms.dart';
// ignore: implementation_imports
import 'package:rivertion/src/internals.dart';

part 'adapters/_reactive_form_sources_extra.dart';
part 'reactive_forms_sources.dart';
part 'riverpod_source_consumer.dart';

class SourceObserver {
  static SourceObserver current = const SourceObserver();

  const SourceObserver();

  void onUncaughtError(Source source, Object error, StackTrace stackTrace) {
    Zone.current.handleUncaughtError(error, stackTrace);
  }
}
