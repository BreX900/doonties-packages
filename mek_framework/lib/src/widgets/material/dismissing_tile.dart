import 'package:flutter/material.dart';

class DismissingTile extends StatelessWidget {
  final bool isLeft;
  final Widget secondary;
  final Widget title;
  final Widget? subtitle;

  const DismissingTile.left({
    super.key,
    required this.secondary,
    required this.title,
    required this.subtitle,
  }) : isLeft = true;

  const DismissingTile.right({
    super.key,
    required this.secondary,
    required this.title,
    this.subtitle,
  }) : isLeft = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData(:textTheme, :listTileTheme) = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeft) ...[secondary, const SizedBox(width: 8.0)],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                DefaultTextStyle(
                  style: listTileTheme.titleTextStyle ?? textTheme.bodyLarge!,
                  child: title,
                ),
                if (subtitle case final subtitle?)
                  DefaultTextStyle(
                    style: listTileTheme.subtitleTextStyle ?? textTheme.bodyMedium!,
                    child: subtitle,
                  ),
              ],
            ),
            if (!isLeft) ...[const SizedBox(width: 8.0), secondary],
          ],
        ),
      ),
    );
  }
}
