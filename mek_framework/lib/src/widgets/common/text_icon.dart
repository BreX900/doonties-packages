import 'package:flutter/widgets.dart';

class TextIcon extends StatelessWidget {
  final String data;
  final Color? color;

  const TextIcon(this.data, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 24.0;

    return SizedBox(
      width: size,
      child: Center(
        child: Text(
          data,
          style: TextStyle(color: color ?? theme.color, fontSize: size),
        ),
      ),
    );
  }
}
