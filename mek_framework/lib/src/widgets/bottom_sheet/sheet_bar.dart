import 'package:flutter/material.dart';

class SheetBar extends StatelessWidget {
  final Widget title;

  const SheetBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final appBarTheme = AppBarTheme.of(context);
    final bottomSheetTheme = theme.bottomSheetTheme;

    final shape = bottomSheetTheme.shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
        );
    final titleTextStyle = appBarTheme.titleTextStyle ?? textTheme.titleLarge;

    return SizedBox(
      height: kToolbarHeight,
      child: Material(
        shape: shape,
        child: NavigationToolbar(
          middle: DefaultTextStyle(
            style: titleTextStyle!,
            child: title,
          ),
          trailing: const CloseButton(),
        ),
      ),
    );
  }
}
