import 'package:flutter/material.dart';

class PopupMenuTileBar extends PopupMenuEntry<Never> {
  @override
  final double height;
  final Widget title;

  const PopupMenuTileBar({
    super.key,
    this.height = 32.0,
    required this.title,
  });

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
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: widget.title,
        ),
      ),
    );
  }
}
