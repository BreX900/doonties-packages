import 'package:flutter/material.dart';

enum _MaterialBarVariant { primary, secondary }

class MaterialBar extends StatefulWidget {
  final _MaterialBarVariant _variant;
  final bool? forceElevated;

  final Widget child;

  const MaterialBar.primary({
    super.key,
    this.forceElevated,
    required this.child,
  }) : _variant = _MaterialBarVariant.primary;

  const MaterialBar.secondary({
    super.key,
    this.forceElevated,
    required this.child,
  }) : _variant = _MaterialBarVariant.secondary;

  @override
  State<MaterialBar> createState() => _MaterialBarState();
}

class _MaterialBarState extends State<MaterialBar> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late ColorTween _color;

  late ThemeData _theme;
  late MaterialInkController _inkController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Durations.medium1,
      value: widget.forceElevated ?? false ? 1.0 : 0.0,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = Theme.of(context);
    _inkController = Material.of(context);
    _color = ColorTween(begin: _inkController.color, end: _theme.colorScheme.surfaceContainer);
  }

  @override
  void didUpdateWidget(covariant MaterialBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.forceElevated != oldWidget.forceElevated) {
      if (widget.forceElevated != null) {
        if (widget.forceElevated!) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final minHeight = switch (widget._variant) {
      _MaterialBarVariant.primary => 48.0,
      _MaterialBarVariant.secondary => 32.0,
    };

    final color = widget.forceElevated != null
        ? _color.animate(_controller).value
        : colors.surfaceContainerLowest;

    return Material(
      animationDuration: Durations.medium1,
      color: color,
      surfaceTintColor: color,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: widget.child,
      ),
    );
  }
}
