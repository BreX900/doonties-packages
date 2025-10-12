import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mek/src/widgets/material/material_surface.dart';

typedef DeferredLibraryLoader = Future<void> Function();

class DeferredLibraryBuilder extends StatefulWidget {
  final DeferredLibraryLoader loader;
  final WidgetBuilder builder;

  const DeferredLibraryBuilder({super.key, required this.loader, required this.builder});

  @override
  State<DeferredLibraryBuilder> createState() => _DeferredLibraryBuilderState();
}

class _DeferredLibraryBuilderState extends State<DeferredLibraryBuilder> {
  // - if loader does not exist, library isn't loaded. Please load the library
  // - if loader does exist with Future, library is loading. Please await the Future
  // - if loader does exist without Future, library is already loaded. Please skip the load
  static final _libraryLoaders = <DeferredLibraryLoader, Future<void>?>{};

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
    // ignore: discarded_futures
    final loading = _libraryLoaders.putIfAbsent(loader, loader);
    _isLoading = loading != null;
    if (loading != null) unawaited(_waitLoading(loader, loading));
  }

  Future<void> _waitLoading(DeferredLibraryLoader loader, Future<void> loading) async {
    await loading;
    _libraryLoaders[loader] = null;

    if (widget.loader != loader) return;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Surface();
    return widget.builder(context);
  }
}
