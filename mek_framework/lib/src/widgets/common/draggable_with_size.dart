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

    final childWhenDragging = Builder(
      builder: (_) {
        final renderBox = context.findRenderObject()! as RenderBox;

        return SizedBox(
          width: renderBox.size.width,
          height: renderBox.size.height,
          child: this.childWhenDragging,
        );
      },
    );
    final feedback = Builder(
      builder: (_) {
        final renderBox = context.findRenderObject()! as RenderBox;

        return SizedBox(
          width: renderBox.size.width,
          height: renderBox.size.height,
          child: this.feedback ?? child,
        );
      },
    );

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
      TargetPlatform.windows => Draggable<T>(
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

class DragTargetWithSize<T extends Object> extends StatefulWidget {
  // ignore: avoid_positional_boolean_parameters
  final void Function(DragTargetDetails<T> details, bool after) onAcceptWithDetails;
  final Widget child;

  const DragTargetWithSize({super.key, required this.onAcceptWithDetails, required this.child});

  @override
  State<DragTargetWithSize<T>> createState() => _DragTargetWithSizeState();
}

class _DragTargetWithSizeState<T extends Object> extends State<DragTargetWithSize<T>> {
  var _isTop = true;

  void _onMove(DragTargetDetails<T> details) {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final localOffset = renderBox.globalToLocal(
      details.offset,
      ancestor: Navigator.of(context, rootNavigator: true).context.findRenderObject(),
    );
    final isTop = localOffset.dy < (size.height / 2);

    if (_isTop == isTop) return;
    setState(() => _isTop = isTop);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onMove: _onMove,
      onAcceptWithDetails: (details) => widget.onAcceptWithDetails(details, !_isTop),
      builder: (context, candidateData, rejectedData) => Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (candidateData.isNotEmpty)
            Positioned.fill(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isTop) const Spacer(),
                  Expanded(
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (_isTop) const Spacer(),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
