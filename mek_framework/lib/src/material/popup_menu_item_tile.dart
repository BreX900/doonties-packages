import 'package:flutter/material.dart';

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
