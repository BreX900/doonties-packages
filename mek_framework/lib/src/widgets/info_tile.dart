import 'package:flutter/material.dart';
import 'package:pure_extensions/pure_extensions.dart';

class InfoTile extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? icon;
  final Widget title;
  final Widget? description;
  final List<Widget> actions;

  const InfoTile({
    super.key,
    this.onTap,
    this.icon,
    required this.title,
    this.description,
    this.actions = const <Widget>[],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme.merge(
              data: const IconThemeData(size: 48.0),
              child: icon ?? const Icon(Icons.info_outline, size: 48.0),
            ),
            const SizedBox(height: 16.0),
            DefaultTextStyle.merge(
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
              child: title,
            ),
            const SizedBox(height: 8.0),
            if (description != null)
              DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                child: description!,
              ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Column(
                children: actions.joinElement(const SizedBox(height: 16.0)).toList(),
              )
            ],
          ],
        ),
      ),
    );
  }
}
