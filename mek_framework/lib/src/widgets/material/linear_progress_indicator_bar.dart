import 'dart:async';

import 'package:flutter/material.dart';

class FlexibleLinearProgressBar extends StatefulWidget {
  final bool visible;
  final double? value;

  const FlexibleLinearProgressBar({
    super.key,
    this.visible = true,
    this.value,
  });

  @override
  State<FlexibleLinearProgressBar> createState() => _FlexibleLinearProgressBarState();
}

class _FlexibleLinearProgressBarState extends State<FlexibleLinearProgressBar>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _topPaddingAnimation;
  var _currentExtent = double.nan;
  var _linearMinHeight = double.nan;

  AnimationController? _valueController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Durations.long2,
      value: widget.visible ? 1.0 : 0.0,
    );
    final value = widget.value;
    if (value != null) _initValueController(value);
    _animationController.addListener(_onAnimationChange);
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
  void didUpdateWidget(covariant FlexibleLinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = widget.value;
    if (value != oldWidget.value) {
      if (value == null) {
        _valueController?.removeListener(_onAnimationChange);
        _valueController?.dispose();
        _valueController = null;
      } else {
        final valueController = _valueController;
        if (valueController == null) {
          _initValueController(value);
        } else {
          valueController.addListener(_onAnimationChange);
          unawaited(valueController.animateTo(value, duration: Durations.long1));
        }
      }
    }
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _valueController?.value = widget.value!;
        unawaited(_animationController.forward());
      } else {
        unawaited(_animationController.reverse());
      }
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationChange);
    _animationController.dispose();
    _valueController?.removeListener(_onAnimationChange);
    _valueController?.dispose();
    super.dispose();
  }

  void _onAnimationChange() {
    setState(_noop);
  }

  void _initValueController(double value) {
    _valueController = AnimationController(vsync: this, value: value);
  }

  @override
  Widget build(BuildContext context) {
    final topPaddingSize = _topPaddingAnimation.value;
    final value = _valueController?.value;

    final isHidden = (topPaddingSize - _currentExtent) > 0.0;
    if (isHidden) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: topPaddingSize),
      child: LinearProgressIndicator(
        minHeight: _linearMinHeight,
        value: value,
      ),
    );
  }
}

void _noop() {}

class CircularProgressIcon extends StatelessWidget {
  const CircularProgressIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);

    return CircularProgressIndicator(
      strokeWidth: theme.weight! / 125,
      constraints: BoxConstraints.tight(Size.square((theme.size ?? 24.0) - 4.0)),
      padding: const EdgeInsets.all(2.0),
      color: theme.color,
    );
  }
}
