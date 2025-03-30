import 'package:flutter/material.dart';

class FixedFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget label;

  const FixedFloatingActionButton.extended({
    super.key,
    required this.onPressed,
    this.icon,
    required this.label,
  });

  (Color, Color) _resolveDisabledColors(BuildContext context) {
    final theme = Theme.of(context);
    final buttonTheme = theme.floatingActionButtonTheme;

    return (
      (buttonTheme.foregroundColor ?? theme.colorScheme.onPrimaryContainer).withValues(alpha: 0.6),
      theme.disabledColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = onPressed == null ? _resolveDisabledColors(context) : null;

    return FloatingActionButton.extended(
      foregroundColor: colors?.$1,
      backgroundColor: colors?.$2,
      onPressed: onPressed,
      icon: icon,
      label: label,
    );
  }
}
