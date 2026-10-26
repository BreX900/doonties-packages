import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/riverpod/notifiers/mutation_controller.dart';

mixin MutableStateMixin<T extends StatefulWidget> on State<T> {
  ModalRoute<dynamic>? _route;
  late final _PopEntry _popEntry;

  final _controller = ValueNotifier(0);
  var _isListening = false;

  var _mutators = <MutationController<Object?>>[];
  late final mutator = mutation<void>();

  bool get isPending {
    if (!_isListening) {
      _controller.addListener(() => setState(() {}));
      _isListening = true;
    }
    return _controller.value > 0;
  }

  @override
  void initState() {
    super.initState();
    _popEntry = _PopEntry(_controller);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute<dynamic>? nextRoute = ModalRoute.of(context);
    if (nextRoute != _route) {
      _route?.unregisterPopEntry(_popEntry);
      _route = nextRoute;
      _route?.registerPopEntry(_popEntry);
    }
  }

  @override
  void dispose() {
    _route?.unregisterPopEntry(_popEntry);
    for (final controller in _mutators) {
      controller.dispose();
    }
    _mutators = const [];
    _controller.dispose();
    super.dispose();
  }

  @optionalTypeArgs
  MutationController<R> mutation<R>() {
    final controller = MutationController<R>.internal(_readContainer, _controller);
    _mutators.add(controller);
    return controller;
  }

  ProviderContainer _readContainer() => ProviderScope.containerOf(context, listen: false);
}

class _PopEntry(final ValueNotifier<int> _controller)
    extends PopEntry<dynamic>
    implements ValueListenable<bool> {
  @override
  ValueListenable<bool> get canPopNotifier => this;

  @override
  bool get value => _controller.value <= 0;

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _controller.removeListener(listener);
}
