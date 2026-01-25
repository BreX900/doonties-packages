import 'dart:async';

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/notifiers/mutation_ref.dart';
import 'package:mek/src/riverpod/notifiers/mutation_state.dart';
import 'package:meta/meta.dart';
import 'package:rivertion/rivertion.dart';

sealed class MutationTarget<T> {}

class Mutation<T> extends MutationTarget<T> {
  static void Function(Object error, StackTrace stackTrace) onError =
      Zone.current.handleUncaughtError;

  final String label;

  Mutation(this.label);

  MutationTarget<T> call(Object? arg) => _MutationFamily._(this, arg);

  @override
  String toString() => 'Mutation#$label';
}

@immutable
final class _MutationFamily<T> extends MutationTarget<T> {
  final Mutation<T> _origin;
  final Object? _arg;

  _MutationFamily._(this._origin, this._arg);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MutationFamily &&
          runtimeType == other.runtimeType &&
          _origin == other._origin &&
          _arg == other._arg;

  @override
  int get hashCode => Object.hash(_origin, _arg);

  @override
  String toString() => '$_origin($_arg)';
}

final class _MutationRef extends MutationRef {
  _MutationRef._(super._ref);

  @override
  bool mounted = true;

  @override
  void updateProgress(double value) {}

  void _dispose() {
    mounted = false;
  }
}

final class _MutationController<T> extends SourceNotifier<MutationState<T>> {
  final ProviderContainer _container;
  final VoidCallback _onDispose;
  var _dependencies = <Element>{};

  _MutationController._(this._container, this._onDispose) : super(MutationState.idle());

  Future<T> run(Future<T> Function(MutationRef ref) body) {
    if (state is MutationPending) throw StateError('Already mutating!');

    state = MutationState.pending();

    return _mutateAsync(body);
  }

  void reset() => state = MutationState.idle();

  // void updateProgress(double value) => state = MutationState.pending(progress: value);

  Future<T> _mutateAsync(Future<T> Function(MutationRef ref) body) async {
    final ref = _MutationRef._(_container);
    try {
      final result = await body(ref);
      if (!mounted) return Completer<T>().future;

      state = MutationState.success(args: ISet<T>.empty(), data: result);
      return result;
    } catch (error, stackTrace) {
      Mutation.onError(error, stackTrace);
      if (!mounted) return Completer<T>().future;

      state = MutationState.error(error, stackTrace);
      rethrow;
    } finally {
      ref._dispose();
      _mayNeedDispose();
    }
  }

  void _addDependency(Element dependent) => _dependencies.add(dependent);

  void _removeDependency(Element dependent) {
    _dependencies.remove(dependent);
    _mayNeedDispose();
  }

  void _mayNeedDispose() {
    if (state is MutationPending) return;
    if (_dependencies.isNotEmpty) return;
    dispose();
    _onDispose();
  }

  @override
  void dispose() {
    _dependencies = const {};
    super.dispose();
  }
}

extension MutationBuildContextExtensions on BuildContext {
  SourceListenable<MutationState<R>> mutation<R>(MutationTarget<R> target) =>
      MutationScope._of<R>(this, target).source;

  @awaitNotRequired
  Future<R> mutate<R>(MutationTarget<R> target, Future<R> Function(MutationRef ref) body) =>
      MutationScope._of(this, target).run(body);
}

class MutationScope extends StatefulWidget {
  final Widget child;

  const MutationScope({super.key, required this.child});

  static _MutationController<R> _of<R>(BuildContext context, MutationTarget<R> target) {
    final model = context.dependOnInheritedWidgetOfExactType<_UncontrolledMutationScope>(
      aspect: target,
    )!;
    return model.state.readController<R>(target);
  }

  @override
  State<MutationScope> createState() => _MutationScopeState();
}

class _MutationScopeState extends State<MutationScope> {
  late Map<MutationTarget<Object?>, _MutationController<Object?>> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers = const {};
    super.dispose();
  }

  _MutationController<R> readController<R>(MutationTarget<R> target) {
    final controller = _controllers[target];
    assert(controller != null, 'You need depend to MutationScope before access to controller!');
    return controller! as _MutationController<R>;
  }

  void createDependency(MutationTarget<Object?> target, Element dependent) {
    final controller = _controllers.putIfAbsent(target, () {
      return _MutationController._(ProviderScope.containerOf(context, listen: false), () {
        _controllers.remove(target);
      });
    });
    controller._addDependency(dependent);
  }

  void removeDependency(MutationTarget<Object?> target, Element dependent) {
    final controller = _controllers[target];
    if (controller == null) return;

    controller._removeDependency(dependent);
  }

  @override
  Widget build(BuildContext context) =>
      _UncontrolledMutationScope(state: this, child: widget.child);
}

class _UncontrolledMutationScope extends InheritedWidget {
  final _MutationScopeState state;

  const _UncontrolledMutationScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_UncontrolledMutationScope oldWidget) => state != oldWidget.state;

  @override
  InheritedElement createElement() => _MutationScopeElement(this);
}

class _MutationScopeElement extends InheritedElement {
  _MutationScopeElement(_UncontrolledMutationScope super.widget);

  _MutationScopeState get _state => (widget as _UncontrolledMutationScope).state;

  @override
  void updateDependencies(Element dependent, covariant MutationTarget<Object?> aspect) {
    final targets = getDependencies(dependent) as Set<MutationTarget>?;
    setDependencies(dependent, <MutationTarget<Object?>>{...?targets, aspect});

    _state.createDependency(aspect, dependent);
  }

  @override
  void removeDependent(Element dependent) {
    if (getDependencies(dependent) case final Set<MutationTarget<Object?>> targets) {
      for (final target in targets) {
        _state.removeDependency(target, dependent);
      }
    }

    super.removeDependent(dependent);
  }
}
