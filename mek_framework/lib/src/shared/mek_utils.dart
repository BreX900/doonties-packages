import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mek/src/data/views.dart';

abstract final class MekUtils {
  static Duration snackBarDuration = const Duration(seconds: 10);
  static String Function(Object error) errorTranslator = _defaultErrorTranslator;

  static void showSnackBarDataError(BuildContext context, ErrorData data) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final backgroundColor = colors.errorContainer;
    final foregroundColor = colors.onErrorContainer;

    late ScaffoldFeatureController controller;
    final timer = Timer(snackBarDuration, () => controller.close());
    controller = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      padding: const EdgeInsets.fromLTRB(0.0, 14.0, 0.0, 14.0),
      duration: const Duration(seconds: 60),
      showCloseIcon: true,
      closeIconColor: foregroundColor,
      backgroundColor: backgroundColor,
      content: InkWell(
        onLongPress: timer.cancel,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.error_outline, color: foregroundColor),
            ),
            Expanded(
              child: Text(
                errorTranslator(data.error),
                style: TextStyle(color: foregroundColor),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  static String _defaultErrorTranslator(Object error) => '$error';
}
