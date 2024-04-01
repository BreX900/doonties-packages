import 'dart:async';

import 'package:flutter/widgets.dart';

typedef DeferredLibraryLoader = Future<void> Function();

class DeferredLibraryBuilder extends StatefulWidget {
  final DeferredLibraryLoader loader;
  final WidgetBuilder builder;

  const DeferredLibraryBuilder({
    super.key,
    required this.loader,
    required this.builder,
  });

  @override
  State<DeferredLibraryBuilder> createState() => _DeferredLibraryBuilderState();
}

class _DeferredLibraryBuilderState extends State<DeferredLibraryBuilder> {
  static final _libraries = <DeferredLibraryLoader, Future<void>?>{};

  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load(widget.loader);
  }

  @override
  void didUpdateWidget(covariant DeferredLibraryBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loader != oldWidget.loader) {
      _load(widget.loader);
    }
  }

  void _load(DeferredLibraryLoader loader) {
    _isLoading = !_libraries.containsKey(loader);
    if (!_isLoading) return;

    final loading = _libraries[loader];
    if (loading != null) {
      unawaited(_waitLoading(loader, loading));
    } else {
      // ignore: discarded_futures
      final loading = loader();
      _libraries[loader] = loading;
      unawaited(_waitLoading(loader, loading));
    }
  }

  Future<void> _waitLoading(DeferredLibraryLoader loader, Future<void> loading) async {
    await loading;
    _libraries[loader] = null;
    if (widget.loader != loader) return;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    return widget.builder(context);
  }
}
