import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class Rotators extends StatefulWidget {
  final bool isRotating;
  final Widget child;

  const Rotators({super.key, required this.isRotating, required this.child});

  @override
  State<Rotators> createState() => _RotatorsState();
}

class _RotatorsState extends State<Rotators> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: math.pi,
    );
    if (widget.isRotating) unawaited(_controller.repeat());
  }

  @override
  void didUpdateWidget(covariant Rotators oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRotating == widget.isRotating) return;
    if (widget.isRotating) {
      unawaited(_controller.repeat());
    } else {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(angle: _controller.value, child: widget.child);
      },
    );
  }
}
