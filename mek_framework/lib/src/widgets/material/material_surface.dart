import 'package:flutter/material.dart';

class Surface extends StatelessWidget {
  final Widget? child;

  const Surface({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: child,
    );
  }
}
