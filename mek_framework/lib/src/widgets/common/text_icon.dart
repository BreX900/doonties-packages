import 'package:flutter/widgets.dart';

class TextIcon extends StatelessWidget {
  final String data;
  final Color? color;

  const TextIcon(this.data, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return Text(
      data,
      style: TextStyle(
        color: color ?? theme.color,
        fontSize: theme.size,
      ),
    );
  }
}
