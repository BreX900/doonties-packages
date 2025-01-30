import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class InfoView extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? icon;
  final Widget title;
  final Widget? description;
  final List<Widget> actions;

  const InfoView({
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                  children: actions.expandIndexed((index, child) sync* {
                    if (index == 0) yield const SizedBox(height: 16.0);
                    yield child;
                  }).toList(),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
