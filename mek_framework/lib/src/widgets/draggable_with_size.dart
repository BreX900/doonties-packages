import 'package:flutter/widgets.dart';

class DraggableWithSize<T extends Object> extends StatelessWidget {
  final T? data;
  final Axis? affinity;
  final Widget childWhenDragging;
  final Widget child;

  const DraggableWithSize({
    super.key,
    this.data,
    this.affinity,
    required this.childWhenDragging,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: data,
      affinity: affinity,
      childWhenDragging: Builder(builder: (_) {
        final renderBox = context.findRenderObject()! as RenderBox;

        return SizedBox(
          width: renderBox.size.width,
          height: renderBox.size.height,
          child: childWhenDragging,
        );
      }),
      feedback: Builder(builder: (_) {
        final renderBox = context.findRenderObject()! as RenderBox;

        return SizedBox(
          width: renderBox.size.width,
          height: renderBox.size.height,
          child: child,
        );
      }),
      child: child,
    );
  }
}
