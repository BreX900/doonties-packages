import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class HarmonicSingleChildScrollView extends StatelessWidget {
  final Axis scrollDirection;
  final Clip clipBehavior;

  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final Widget child;
  final DragStartBehavior dragStartBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  const HarmonicSingleChildScrollView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.clipBehavior = Clip.none,
    this.reverse = false,
    this.padding,
    this.primary,
    this.physics,
    this.controller,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  Widget build(BuildContext context) {
    final child = IntrinsicHeight(
      child: this.child,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        padding: padding,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        dragStartBehavior: dragStartBehavior,
        clipBehavior: clipBehavior,
        restorationId: restorationId,
        keyboardDismissBehavior: keyboardDismissBehavior,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: switch (scrollDirection) {
              Axis.vertical => constraints.maxHeight - (padding?.vertical ?? 0.0),
              Axis.horizontal => 0.0,
            },
            minWidth: switch (scrollDirection) {
              Axis.vertical => 0.0,
              Axis.horizontal => constraints.maxWidth - (padding?.horizontal ?? 0.0),
            },
          ),
          child: child,
        ),
      );
    });
  }
}
