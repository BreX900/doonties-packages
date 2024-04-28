import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DraggableWithSize<T extends Object> extends StatelessWidget {
  final T? data;
  final Axis? affinity;
  final Widget childWhenDragging;
  final Widget? feedback;
  final Widget child;

  const DraggableWithSize({
    super.key,
    this.data,
    this.affinity,
    required this.childWhenDragging,
    this.feedback,
    required this.child,
  });

  void _onDragStarted() => unawaited(HapticFeedback.lightImpact());

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    final childWhenDragging = Builder(builder: (_) {
      final renderBox = context.findRenderObject()! as RenderBox;

      return SizedBox(
        width: renderBox.size.width,
        height: renderBox.size.height,
        child: this.childWhenDragging,
      );
    });
    final feedback = Builder(builder: (_) {
      final renderBox = context.findRenderObject()! as RenderBox;

      return SizedBox(
        width: renderBox.size.width,
        height: renderBox.size.height,
        child: this.feedback ?? child,
      );
    });

    return switch (platform) {
      TargetPlatform.android || TargetPlatform.iOS => LongPressDraggable<T>(
          data: data,
          onDragStarted: _onDragStarted,
          childWhenDragging: childWhenDragging,
          feedback: feedback,
          child: child,
        ),
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.macOS ||
      TargetPlatform.windows =>
        Draggable<T>(
          data: data,
          affinity: affinity,
          onDragStarted: _onDragStarted,
          childWhenDragging: childWhenDragging,
          feedback: feedback,
          child: child,
        ),
    };
  }
}
