import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

abstract interface class Disposable {
  void dispose();
}

abstract class DisposerProvider {
  Disposer get _disposer;
}

extension on DisposerProvider {
  void _add(VoidCallback disposer) => _disposer.add(disposer);
}

class Disposer implements DisposerProvider {
  final _entries = <VoidCallback>[];

  void add(VoidCallback disposer) {
    _entries.add(disposer);
  }

  void remove(VoidCallback disposer, {bool shouldDispose = false}) {
    if (!_entries.remove(disposer)) return;
    if (shouldDispose) disposer();
  }

  void dispose() {
    _entries.forEach(Zone.current.runGuarded);
  }

  @override
  Disposer get _disposer => this;
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
  void disposeBy(DisposerProvider disposer) => disposer._add(cancel);
}

extension DisposableCompositeSubscriptionExtension on CompositeSubscription {
  void disposeBy(DisposerProvider disposer) => disposer._add(cancel);
}

extension DisposableChangeNotifierExtension on ChangeNotifier {
  void disposeBy(DisposerProvider disposer) => disposer._add(dispose);
}

extension DisposableValueNotifierExtension<T> on ValueNotifier<T> {
  void disposeBy(DisposerProvider disposer) => disposer._add(dispose);
}

extension DisposableBlocExtension<State> on BlocBase<State> {
  void disposeBy(DisposerProvider disposer) => disposer._add(close);
}

extension DisposableStateNotifierExtension<State> on StateNotifier<State> {
  void disposeBy(DisposerProvider disposer) => disposer._add(dispose);
}
