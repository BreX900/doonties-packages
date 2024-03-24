import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:mek/src/form/shared/group_style.dart';

/// based on the [style] you want to apply.
class GroupView extends StatelessWidget {
  /// You can use:
  /// - [FlexGroupStyle] use a [Flex] widget. ([Column] or [Row])
  /// - [TableGroupStyle] uses a combination of [Column] and [Row] widgets
  ///   to create a table
  /// - [WrapGroupStyle] use a [Wrap] widget
  final GroupStyle style;

  /// Padding of the items the group
  final EdgeInsetsGeometry? padding;

  /// Quantity of the items in the group
  final int count;

  /// Builder of the items in the group
  final IndexedWidgetBuilder builder;

  const GroupView({
    super.key,
    required this.style,
    this.padding,
    required this.count,
    required this.builder,
  }) : assert(count >= 0);

  Iterable<Widget> _generateChildren(BuildContext context) sync* {
    for (var i = 0; i < count; i++) {
      yield builder(context, i);
    }
  }

  Widget _buildPadded(Widget child) {
    if (padding != null) {
      return Padding(
        padding: padding!,
        child: child,
      );
    }
    return child;
  }

  Widget _buildLayout(BuildContext context, GroupStyle style) {
    if (style is FlexGroupStyle) {
      return _buildPadded(Flex(
        direction: style.direction,
        textDirection: style.textDirection,
        verticalDirection: style.verticalDirection,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateChildren(context).toList(),
      ));
    } else if (style is TableGroupStyle) {
      final children = _generateChildren(context).map((child) {
        return Expanded(child: child);
      }).splitBetweenIndexed((index, _, __) {
        return (index % style.crossAxisCount) == 0;
      });
      return _buildPadded(Column(
        textDirection: style.textDirection,
        verticalDirection: style.mainVerticalDirection,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((children) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            verticalDirection: style.crossVerticalDirection,
            children: children,
          );
        }).toList(),
      ));
    } else if (style is WrapGroupStyle) {
      return _buildPadded(Wrap(
        direction: style.direction,
        alignment: style.alignment,
        spacing: style.spacing,
        runAlignment: style.runAlignment,
        runSpacing: style.runSpacing,
        crossAxisAlignment: style.crossAxisAlignment,
        textDirection: style.textDirection,
        verticalDirection: style.verticalDirection,
        children: _generateChildren(context).toList(),
      ));
    } else if (style is ListGroupStyle) {
      return SizedBox(
        height: style.height,
        width: style.width,
        child: ListView.builder(
          controller: style.controller,
          primary: style.primary,
          scrollDirection: style.scrollDirection,
          reverse: style.reverse,
          physics: style.physics,
          padding: padding,
          itemCount: count,
          itemBuilder: builder,
        ),
      );
    } else if (style is GridGroupStyle) {
      return SizedBox(
        height: style.height,
        width: style.width,
        child: GridView.builder(
          controller: style.controller,
          primary: style.primary,
          scrollDirection: style.scrollDirection,
          reverse: style.reverse,
          physics: style.physics,
          gridDelegate: style.gridDelegate,
          padding: padding,
          itemCount: count,
          itemBuilder: builder,
        ),
      );
    }
    throw StateError('Not support ${style.runtimeType} style');
  }

  @override
  Widget build(BuildContext context) => _buildLayout(context, style);
}
