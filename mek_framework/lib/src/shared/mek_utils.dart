import 'dart:async';

import 'package:flutter/material.dart';

abstract final class MekUtils {
  static void showSnackBarError({
    required BuildContext context,
    required Widget description,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = colors.errorContainer;
    final foregroundColor = colors.onErrorContainer;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      padding: EdgeInsets.zero,
      duration: const Duration(seconds: 5 * 60),
      showCloseIcon: false,
      closeIconColor: foregroundColor,
      backgroundColor: backgroundColor,
      content: _ErrorSnackBarContent(
        foregroundColor: foregroundColor,
        description: description,
      ),
    ));
  }
}

class _ErrorSnackBarContent extends StatefulWidget {
  final Color foregroundColor;
  final Widget description;

  const _ErrorSnackBarContent({
    required this.foregroundColor,
    required this.description,
  });

  @override
  State<_ErrorSnackBarContent> createState() => _ErrorSnackBarContentState();
}

class _ErrorSnackBarContentState extends State<_ErrorSnackBarContent>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward().whenComplete(_close));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    _controller.value = 0.0;
  }

  void _close() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _cancel,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 14.0, 0.0, 14.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.error_outline, color: widget.foregroundColor),
                ),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: widget.foregroundColor),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    child: widget.description,
                  ),
                ),
                IconButton(
                  onPressed: _close,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.value == 0.0) return const SizedBox.shrink();
                return LinearProgressIndicator(value: _controller.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
