import 'package:flutter/material.dart';

class PopupMenuArea<T> extends StatelessWidget {
  final List<PopupMenuEntry<T>> items;
  final Widget child;

  const PopupMenuArea({super.key, required this.items, required this.child});

  Future<void> _show(BuildContext context, Offset offset) async {
    final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;

    await showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        overlay.size.width - offset.dx,
        overlay.size.height - offset.dy,
      ),
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: items.isNotEmpty
          ? (details) => _show(context, details.globalPosition)
          : null,
      onLongPressStart: items.isNotEmpty
          ? (details) => _show(context, details.globalPosition)
          : null,
      child: child,
    );
  }
}
