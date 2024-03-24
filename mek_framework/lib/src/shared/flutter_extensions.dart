import 'package:flutter/material.dart';

extension TargetPlatformExtensions on TargetPlatform {
  bool get isDesktop {
    switch (this) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return false;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
    }
  }
}

Future<T?> showPopupMenu<T>({
  required BuildContext context,
  PopupMenuPosition? position,
  Offset offset = Offset.zero,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  required List<PopupMenuEntry<T>> items,
}) {
  final popupMenuTheme = PopupMenuTheme.of(context);
  final button = context.findRenderObject()! as RenderBox;
  final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final popupMenuPosition = position ?? popupMenuTheme.position ?? PopupMenuPosition.over;
  final Offset targetOffset;
  switch (popupMenuPosition) {
    case PopupMenuPosition.over:
      targetOffset = offset;
    case PopupMenuPosition.under:
      targetOffset = Offset(0.0, button.size.height - (padding.vertical / 2)) + offset;
  }
  final relativePosition = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(targetOffset, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero) + targetOffset, ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  return showMenu(
    context: context,
    // elevation: widget.elevation ?? popupMenuTheme.elevation,
    // shadowColor: widget.shadowColor ?? popupMenuTheme.shadowColor,
    // surfaceTintColor: widget.surfaceTintColor ?? popupMenuTheme.surfaceTintColor,
    items: items,
    // initialValue: widget.initialValue,
    position: relativePosition,
    // shape: widget.shape ?? popupMenuTheme.shape,
    // color: widget.color ?? popupMenuTheme.color,
    // constraints: widget.constraints,
    // clipBehavior: widget.clipBehavior,
  );
}

@Deprecated('In favour of showPopupMenu')
Future<void> showTappableMenu({
  required BuildContext context,
  PopupMenuPosition? position,
  Offset offset = Offset.zero,
  EdgeInsetsGeometry padding = EdgeInsets.zero,
  required List<PopupMenuEntry<VoidCallback>> items,
}) {
  return showPopupMenu<VoidCallback?>(
    context: context,
    position: position,
    offset: offset,
    padding: padding,
    items: items,
  ).then((onTap) {
    onTap?.call();
  });
}
