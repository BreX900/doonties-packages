import 'package:flutter/widgets.dart';

class TextIcon extends StatelessWidget {
  final String data;

  const TextIcon(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    return Text(
      data,
      style: TextStyle(
        color: theme.color,
        fontSize: theme.size,
      ),
    );
  }
}
