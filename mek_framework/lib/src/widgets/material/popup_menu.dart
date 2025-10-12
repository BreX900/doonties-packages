import 'package:flutter/material.dart';

class PopupMenuTileBar extends PopupMenuEntry<Never> {
  @override
  final double height;
  final Widget title;

  const PopupMenuTileBar({super.key, this.height = 32.0, required this.title});

  @override
  bool represents(void value) => false;

  @override
  State<StatefulWidget> createState() => _PopupMenuDecorationState();
}

class _PopupMenuDecorationState extends State<PopupMenuTileBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Align(alignment: AlignmentDirectional.centerStart, child: widget.title),
      ),
    );
  }
}

class PopupMenuItemTile<T> extends PopupMenuItem<T> {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const PopupMenuItemTile({
    super.key,
    super.enabled,
    super.value,
    super.onTap,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  }) : super(child: const SizedBox.shrink());

  @override
  bool represents(T? value) => value == this.value;

  @override
  PopupMenuItemState<T, PopupMenuItem<T>> createState() => _PopupMenuItemTileState();
}

class _PopupMenuItemTileState<T> extends PopupMenuItemState<T, PopupMenuItemTile<T>> {
  @override
  Widget buildChild() {
    return ListTile(
      enabled: widget.enabled,
      leading: widget.leading,
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: widget.trailing,
    );
  }
}
