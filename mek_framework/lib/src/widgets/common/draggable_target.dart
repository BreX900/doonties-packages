import 'package:flutter/material.dart';

enum DraggableTargetDestination { before, after }

class DraggableTarget<T extends Object> extends StatefulWidget {
  final T data;
  final void Function(DraggableTargetDestination position, T data) onAccepted;
  final Axis direction;
  final Widget child;

  const DraggableTarget({
    super.key,
    required this.data,
    required this.onAccepted,
    required this.direction,
    required this.child,
  });

  @override
  State<DraggableTarget<T>> createState() => _DraggableTargetState();
}

class _DraggableTargetState<T extends Object> extends State<DraggableTarget<T>>
    with TickerProviderStateMixin {
  final _key = GlobalKey();

  late final _disappearAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: 1.0,
  );

  @override
  void dispose() {
    _disappearAnimation.dispose();
    super.dispose();
  }

  void _expand([_, _]) => _disappearAnimation.forward();

  void _collapse() => _disappearAnimation.reverse();

  Widget _buildTarget(DraggableTargetDestination position) {
    final theme = Theme.of(context);

    return DragTarget<T>(
      onWillAcceptWithDetails: (details) => details.data != widget.data,
      onAcceptWithDetails: (details) => widget.onAccepted(position, details.data),
      builder: (context, candidateData, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: candidateData.isEmpty
              ? const SizedBox.expand()
              : ColoredBox(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  child: const SizedBox.expand(),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Draggable(
          onDragStarted: _collapse,
          onDragEnd: _expand,
          onDraggableCanceled: _expand,
          onDragCompleted: _expand,
          data: widget.data,
          feedback: Builder(
            builder: (context) => SizedBox.fromSize(
              size: (_key.currentContext!.findRenderObject()! as RenderBox).size,
              child: Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: widget.child,
              ),
            ),
          ),
          childWhenDragging: SizeTransition(
            sizeFactor: _disappearAnimation,
            child: Opacity(opacity: 0.0, child: widget.child),
          ),
          child: KeyedSubtree(key: _key, child: widget.child),
        ),
        Positioned.fill(
          child: Flex(
            direction: widget.direction,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildTarget(DraggableTargetDestination.before)),
              Expanded(child: _buildTarget(DraggableTargetDestination.after)),
            ],
          ),
        ),
      ],
    );
  }
}
