import 'package:flutter/material.dart';

class LinearProgressIndicatorBar extends StatefulWidget {
  final bool isHidden;
  final double? value;

  bool get isVisible => !isHidden;

  const LinearProgressIndicatorBar({
    super.key,
    @Deprecated('In favour of isHidden') bool? isVisible,
    bool? isHidden = false,
    this.value,
  }) : isHidden = isHidden ?? isVisible ?? false;

  @override
  State<LinearProgressIndicatorBar> createState() => _LinearProgressIndicatorBarState();
}

class _LinearProgressIndicatorBarState extends State<LinearProgressIndicatorBar>
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
      value: widget.isVisible ? 1.0 : 0.0,
    );
    final value = widget.value;
    if (value != null) _initValueController(value);
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
    final value = widget.value;
    if (value != oldWidget.value) {
      if (value == null) {
        _valueController?.dispose();
        _valueController = null;
      } else {
        final valueController = _valueController;
        if (valueController == null) {
          _initValueController(value);
        } else {
          valueController.animateTo(value, duration: Durations.long1);
        }
      }
    }
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _valueController?.value = widget.value!;
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _valueController?.dispose();
    super.dispose();
  }

  void _initValueController(double value) {
    _valueController = AnimationController(vsync: this, value: value);
  }

  Widget _buildLinearProgressIndicator(BuildContext context, [double? value, Widget? _]) {
    return LinearProgressIndicator(
      minHeight: _linearMinHeight,
      value: value,
    );
  }

  Widget _buildAppearAnimation(BuildContext context, double value, Widget? _) {
    final isHidden = (value - _currentExtent) > 0.0;
    if (isHidden) return const SizedBox.shrink();

    final valueController = _valueController;
    final child = valueController == null
        ? _buildLinearProgressIndicator(context)
        : ValueListenableBuilder(
            valueListenable: valueController,
            builder: _buildLinearProgressIndicator,
          );

    return Padding(
      padding: EdgeInsets.only(top: value),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _topPaddingAnimation,
      builder: _buildAppearAnimation,
    );
  }
}
