import 'package:flutter/material.dart';

enum _MaterialBarVariant { primary, secondary }

class MaterialBar extends StatelessWidget {
  final _MaterialBarVariant _variant;
  final bool forceElevated;
  final Widget child;

  const MaterialBar.primary({
    super.key,
    this.forceElevated = false,
    required this.child,
  }) : _variant = _MaterialBarVariant.primary;

  const MaterialBar.secondary({
    super.key,
    this.forceElevated = false,
    required this.child,
  }) : _variant = _MaterialBarVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final surface = Material.of(context).color!;

    final surfaceContainer = switch (_variant) {
      _MaterialBarVariant.primary => colors.surfaceContainer,
      _MaterialBarVariant.secondary => colors.surfaceContainer,
    };
    final minHeight = switch (_variant) {
      _MaterialBarVariant.primary => 48.0,
      _MaterialBarVariant.secondary => 32.0,
    };

    return Material(
      color: forceElevated ? surfaceContainer : surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: child,
      ),
    );
  }
}
