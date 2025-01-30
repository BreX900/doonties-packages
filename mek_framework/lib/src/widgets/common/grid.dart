import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class Grid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  const Grid({
    super.key,
    required this.crossAxisCount,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.slices(crossAxisCount).map((cells) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cells.map((e) => Expanded(child: e)).toList(),
        );
      }).toList(),
    );
  }
}
