import 'package:flutter/material.dart';

class LinearProgressIndicatorBar extends StatefulWidget {
  final bool isVisible;

  const LinearProgressIndicatorBar({
    super.key,
    this.isVisible = true,
  });

  @override
  State<LinearProgressIndicatorBar> createState() => _LinearProgressIndicatorBarState();
}

class _LinearProgressIndicatorBarState extends State<LinearProgressIndicatorBar>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _topPaddingAnimation;
  var _currentExtent = double.nan;
  var _linearMinHeight = double.nan;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Durations.long2,
      value: widget.isVisible ? 1.0 : 0.0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final indicatorTheme = Theme.of(context).progressIndicatorTheme;
    final linearMinHeight = indicatorTheme.linearMinHeight ?? 4.0;
    final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

    if (_linearMinHeight != linearMinHeight || _currentExtent != settings.currentExtent) {
      _currentExtent = settings.currentExtent;
      _linearMinHeight = linearMinHeight;

      _topPaddingAnimation = _animationController.drive(Tween(
        begin: _currentExtent,
        end: _currentExtent - _linearMinHeight,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant LinearProgressIndicatorBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _topPaddingAnimation,
      builder: (context, value, _) {
        final isHidden = (value - _currentExtent) > 0.0;
        if (isHidden) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(top: value),
          child: LinearProgressIndicator(minHeight: _linearMinHeight),
        );
      },
    );
  }
}
