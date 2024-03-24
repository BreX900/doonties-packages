import 'package:flutter/widgets.dart';
import 'package:mek/src/form/shared/group_view.dart';
import 'package:mek_data_class/mek_data_class.dart';

part 'group_style.g.dart';

/// Base class for the style of [GroupView]
class GroupStyle {
  const GroupStyle._();

  const factory GroupStyle.flex({
    Axis direction,
    TextDirection? textDirection,
    VerticalDirection verticalDirection,
  }) = FlexGroupStyle;
  const factory GroupStyle.table({
    TextDirection? textDirection,
    VerticalDirection mainVerticalDirection,
    VerticalDirection crossVerticalDirection,
    int crossAxisCount,
  }) = TableGroupStyle;
  const factory GroupStyle.wrap() = WrapGroupStyle;
  const factory GroupStyle.list() = ListGroupStyle;
  const factory GroupStyle.grid({
    ScrollController? controller,
    bool? primary,
    Axis scrollDirection,
    bool reverse,
    ScrollPhysics? physics,
    required SliverGridDelegate gridDelegate,
    double? height,
    double? width,
  }) = GridGroupStyle;
}

/// [Flex]
@DataClass()
class FlexGroupStyle extends GroupStyle with _$FlexGroupStyle {
  /// [Flex.direction]
  final Axis direction;

  /// [Flex.textDirection]
  final TextDirection? textDirection;

  /// [Flex.verticalDirection]
  final VerticalDirection verticalDirection;

  const FlexGroupStyle({
    this.direction = Axis.vertical,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
  }) : super._();
}

/// Similar to [Table] without borders or [GridView] without scroll
@DataClass()
class TableGroupStyle extends GroupStyle with _$TableGroupStyle {
  /// [Flex.textDirection]
  final TextDirection? textDirection;

  /// [Flex.verticalDirection]
  final VerticalDirection mainVerticalDirection;

  /// [Flex.verticalDirection]
  final VerticalDirection crossVerticalDirection;

  final int crossAxisCount;

  const TableGroupStyle({
    this.textDirection,
    this.mainVerticalDirection = VerticalDirection.down,
    this.crossVerticalDirection = VerticalDirection.down,
    this.crossAxisCount = 2,
  })  : assert(crossAxisCount >= 2),
        super._();
}

/// [Wrap]
@DataClass()
class WrapGroupStyle extends GroupStyle with _$WrapGroupStyle {
  /// [Wrap.direction]
  final Axis direction;

  /// [Wrap.alignment]
  final WrapAlignment alignment;

  /// [Wrap.spacing]
  final double spacing;

  /// [Wrap.runAlignment]
  final WrapAlignment runAlignment;

  /// [Wrap.runSpacing]
  final double runSpacing;

  /// [Wrap.crossAxisAlignment]
  final WrapCrossAlignment crossAxisAlignment;

  /// [Wrap.textDirection]
  final TextDirection? textDirection;

  /// [Wrap.verticalDirection]
  final VerticalDirection verticalDirection;

  /// [Wrap.clipBehavior]
  final Clip clipBehavior;

  const WrapGroupStyle({
    this.direction = Axis.horizontal,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.clipBehavior = Clip.none,
  }) : super._();
}

/// [ListView]
@DataClass()
class ListGroupStyle extends GroupStyle with _$ListGroupStyle {
  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// Fixed height of the group
  final double? height;

  /// Fixed width of the group
  final double? width;

  /// Pass either the [height] or the [width] according
  /// to the layout direction of the parent widget
  const ListGroupStyle({
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.height,
    this.width,
  }) : super._();
}

/// [GridView]
@DataClass()
class GridGroupStyle extends GroupStyle with _$GridGroupStyle {
  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// [GridView.gridDelegate]
  final SliverGridDelegate gridDelegate;

  /// Fixed height of the group
  final double? height;

  /// Fixed width of the group
  final double? width;

  /// Pass either the [height] or the [width] according
  /// to the layout direction of the parent widget
  const GridGroupStyle({
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    required this.gridDelegate,
    this.height,
    this.width,
  }) : super._();
}
