import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FloatingActionButtonInjector extends StatefulWidget {
  const FloatingActionButtonInjector({super.key});

  @override
  State<FloatingActionButtonInjector> createState() => _FloatingActionButtonInjectorState();
}

class _FloatingActionButtonInjectorState extends State<FloatingActionButtonInjector> {
  ValueListenable<ScaffoldGeometry>? _geometryListenable;
  var _height = 56.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _geometryListenable?.removeListener(_onGeometryChange);
    _geometryListenable = Scaffold.geometryOf(context);
    _geometryListenable!.addListener(_onGeometryChange);
  }

  @override
  void dispose() {
    _geometryListenable!.removeListener(_onGeometryChange);
    super.dispose();
  }

  void _onGeometryChange() {
    _findFloatingActionButtonHeight();
  }

  void _findFloatingActionButtonHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scaffold = context.findAncestorStateOfType<ScaffoldState>();
      var height = 0.0;
      void visitor(Element element) {
        if (element.widget is Hero) {
          height = (element.findRenderObject()! as RenderBox).size.height;
          return;
        }
        element.visitChildren(visitor);
      }

      scaffold?.context.visitChildElements(visitor);

      if (_height == height) return;
      setState(() => _height = height);
    });
  }

  @override
  Widget build(BuildContext context) {
    _findFloatingActionButtonHeight();
    return SizedBox(height: _height + (kFloatingActionButtonMargin * 2));
  }
}
