// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_style.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$FlexGroupStyle {
  FlexGroupStyle get _self => this as FlexGroupStyle;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlexGroupStyle &&
          runtimeType == other.runtimeType &&
          _self.direction == other.direction &&
          _self.textDirection == other.textDirection &&
          _self.verticalDirection == other.verticalDirection;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.direction.hashCode);
    hashCode = $hashCombine(hashCode, _self.textDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.verticalDirection.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('FlexGroupStyle')
        ..add('direction', _self.direction)
        ..add('textDirection', _self.textDirection)
        ..add('verticalDirection', _self.verticalDirection))
      .toString();
}

mixin _$TableGroupStyle {
  TableGroupStyle get _self => this as TableGroupStyle;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableGroupStyle &&
          runtimeType == other.runtimeType &&
          _self.textDirection == other.textDirection &&
          _self.mainVerticalDirection == other.mainVerticalDirection &&
          _self.crossVerticalDirection == other.crossVerticalDirection &&
          _self.crossAxisCount == other.crossAxisCount;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.textDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.mainVerticalDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.crossVerticalDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.crossAxisCount.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('TableGroupStyle')
        ..add('textDirection', _self.textDirection)
        ..add('mainVerticalDirection', _self.mainVerticalDirection)
        ..add('crossVerticalDirection', _self.crossVerticalDirection)
        ..add('crossAxisCount', _self.crossAxisCount))
      .toString();
}

mixin _$WrapGroupStyle {
  WrapGroupStyle get _self => this as WrapGroupStyle;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WrapGroupStyle &&
          runtimeType == other.runtimeType &&
          _self.direction == other.direction &&
          _self.alignment == other.alignment &&
          _self.spacing == other.spacing &&
          _self.runAlignment == other.runAlignment &&
          _self.runSpacing == other.runSpacing &&
          _self.crossAxisAlignment == other.crossAxisAlignment &&
          _self.textDirection == other.textDirection &&
          _self.verticalDirection == other.verticalDirection &&
          _self.clipBehavior == other.clipBehavior;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.direction.hashCode);
    hashCode = $hashCombine(hashCode, _self.alignment.hashCode);
    hashCode = $hashCombine(hashCode, _self.spacing.hashCode);
    hashCode = $hashCombine(hashCode, _self.runAlignment.hashCode);
    hashCode = $hashCombine(hashCode, _self.runSpacing.hashCode);
    hashCode = $hashCombine(hashCode, _self.crossAxisAlignment.hashCode);
    hashCode = $hashCombine(hashCode, _self.textDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.verticalDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.clipBehavior.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('WrapGroupStyle')
        ..add('direction', _self.direction)
        ..add('alignment', _self.alignment)
        ..add('spacing', _self.spacing)
        ..add('runAlignment', _self.runAlignment)
        ..add('runSpacing', _self.runSpacing)
        ..add('crossAxisAlignment', _self.crossAxisAlignment)
        ..add('textDirection', _self.textDirection)
        ..add('verticalDirection', _self.verticalDirection)
        ..add('clipBehavior', _self.clipBehavior))
      .toString();
}

mixin _$ListGroupStyle {
  ListGroupStyle get _self => this as ListGroupStyle;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListGroupStyle &&
          runtimeType == other.runtimeType &&
          _self.controller == other.controller &&
          _self.primary == other.primary &&
          _self.scrollDirection == other.scrollDirection &&
          _self.reverse == other.reverse &&
          _self.physics == other.physics &&
          _self.height == other.height &&
          _self.width == other.width;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.controller.hashCode);
    hashCode = $hashCombine(hashCode, _self.primary.hashCode);
    hashCode = $hashCombine(hashCode, _self.scrollDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.reverse.hashCode);
    hashCode = $hashCombine(hashCode, _self.physics.hashCode);
    hashCode = $hashCombine(hashCode, _self.height.hashCode);
    hashCode = $hashCombine(hashCode, _self.width.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('ListGroupStyle')
        ..add('controller', _self.controller)
        ..add('primary', _self.primary)
        ..add('scrollDirection', _self.scrollDirection)
        ..add('reverse', _self.reverse)
        ..add('physics', _self.physics)
        ..add('height', _self.height)
        ..add('width', _self.width))
      .toString();
}

mixin _$GridGroupStyle {
  GridGroupStyle get _self => this as GridGroupStyle;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridGroupStyle &&
          runtimeType == other.runtimeType &&
          _self.controller == other.controller &&
          _self.primary == other.primary &&
          _self.scrollDirection == other.scrollDirection &&
          _self.reverse == other.reverse &&
          _self.physics == other.physics &&
          _self.gridDelegate == other.gridDelegate &&
          _self.height == other.height &&
          _self.width == other.width;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.controller.hashCode);
    hashCode = $hashCombine(hashCode, _self.primary.hashCode);
    hashCode = $hashCombine(hashCode, _self.scrollDirection.hashCode);
    hashCode = $hashCombine(hashCode, _self.reverse.hashCode);
    hashCode = $hashCombine(hashCode, _self.physics.hashCode);
    hashCode = $hashCombine(hashCode, _self.gridDelegate.hashCode);
    hashCode = $hashCombine(hashCode, _self.height.hashCode);
    hashCode = $hashCombine(hashCode, _self.width.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('GridGroupStyle')
        ..add('controller', _self.controller)
        ..add('primary', _self.primary)
        ..add('scrollDirection', _self.scrollDirection)
        ..add('reverse', _self.reverse)
        ..add('physics', _self.physics)
        ..add('gridDelegate', _self.gridDelegate)
        ..add('height', _self.height)
        ..add('width', _self.width))
      .toString();
}
