import 'package:flutter/material.dart';

class CopyToClipboardButtonIcon extends StatelessWidget {
  final VoidCallback? onPressed;

  const CopyToClipboardButtonIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: const Icon(Icons.copy));
  }
}
