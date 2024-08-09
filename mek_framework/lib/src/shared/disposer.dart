import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

abstract class DisposerProvider {
  Disposer get _disposer;
}

class Disposer implements DisposerProvider {
  final _entries = <VoidCallback>[];
  @override
  Disposer get _disposer => this;

  void add(VoidCallback disposer) {
    _entries.add(disposer);
  }

  void remove(VoidCallback disposer, {bool shouldDispose = true}) {
    if (!_entries.remove(disposer)) return;
    if (shouldDispose) disposer();
  }

  void dispose() {
    for (final disposer in _entries) {
      disposer();
    }
  }
}

mixin StateDisposer<T extends StatefulWidget> on State<T> implements DisposerProvider {
  @override
  final _disposer = Disposer();

  @override
  void dispose() {
    _disposer.dispose();
    super.dispose();
  }
}

mixin ChangeNotifierDisposer on ChangeNotifier implements DisposerProvider {
  @override
  final _disposer = Disposer();

  @override
  void dispose() {
    _disposer.dispose();
    super.dispose();
  }
}

mixin ValueNotifierDisposer on ValueNotifier implements DisposerProvider {
  @override
  final _disposer = Disposer();

  @override
  void dispose() {
    _disposer.dispose();
    super.dispose();
  }
}

mixin BlocDisposer<T> on BlocBase<T> implements DisposerProvider {
  @override
  final _disposer = Disposer();

  @override
  Future<void> close() {
    _disposer.dispose();
    return super.close();
  }
}

mixin StateNotifierDisposer<T> on StateNotifier<T> implements DisposerProvider {
  @override
  final _disposer = Disposer();

  @override
  void dispose() {
    _disposer.dispose();
    super.dispose();
  }
}

extension DisposableStreamSubscriptionExtension<T> on StreamSubscription<T> {
  void addToDisposer(DisposerProvider disposer) => disposer._disposer.add(cancel);
}

extension DisposableBlocExtension<State> on BlocBase<State> {
  void addToDisposer(DisposerProvider disposer) => disposer._disposer.add(close);
}

extension DisposableCompositeSubscriptionExtension on CompositeSubscription {
  void addToDisposer(DisposerProvider disposer) => disposer._disposer.add(cancel);
}
