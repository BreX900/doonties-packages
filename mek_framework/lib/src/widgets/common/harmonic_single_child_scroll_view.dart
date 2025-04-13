import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class HarmonicSingleChildScrollView extends StatelessWidget {
  final bool resizeToAvoidBottomInset;
  final bool hasIntrinsicBody;
  final Axis scrollDirection;
  final Clip clipBehavior;

  final bool reverse;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final Widget child;
  final DragStartBehavior dragStartBehavior;
  final HitTestBehavior hitTestBehavior;
  final String? restorationId;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  const HarmonicSingleChildScrollView({
    super.key,
    this.resizeToAvoidBottomInset = true,
    this.hasIntrinsicBody = false,
    this.scrollDirection = Axis.vertical,
    this.clipBehavior = Clip.hardEdge,
    this.reverse = false,
    this.padding = EdgeInsets.zero,
    this.primary,
    this.physics,
    this.controller,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.restorationId,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewInsets = resizeToAvoidBottomInset ? MediaQuery.viewInsetsOf(context) : null;

    var child = this.child;
    if (hasIntrinsicBody) {
      child = switch (scrollDirection) {
        Axis.horizontal => IntrinsicWidth(child: child),
        Axis.vertical => IntrinsicHeight(child: child),
      };
    }

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        padding: (viewInsets?.add(padding) ?? padding).add(viewPadding),
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics,
        dragStartBehavior: dragStartBehavior,
        clipBehavior: clipBehavior,
        hitTestBehavior: hitTestBehavior,
        restorationId: restorationId,
        keyboardDismissBehavior: keyboardDismissBehavior,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: switch (scrollDirection) {
              Axis.vertical => constraints.maxHeight - padding.vertical - viewPadding.vertical,
              Axis.horizontal => 0.0,
            },
            minWidth: switch (scrollDirection) {
              Axis.vertical => 0.0,
              Axis.horizontal => constraints.maxWidth - padding.horizontal - viewPadding.vertical,
            },
          ),
          child: child,
        ),
      );
    });
  }
}
