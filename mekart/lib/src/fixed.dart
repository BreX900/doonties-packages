import 'dart:math' as math_lib;

import 'package:decimal/decimal.dart';
import 'package:meta/meta.dart';
// ignore: depend_on_referenced_packages
import 'package:rational/rational.dart';

extension on num {
  Fixed toFixed() {
    final value = this;
    assert(value.isFinite, 'Value ($this) is not finite number.');
    return value is int ? Fixed.fromInt(value) : Fixed.parse('$this');
  }
}

extension on Rational {
  Decimal toFixedDecimal() => toDecimal(scaleOnInfinitePrecision: Fixed.defaultPrecision);
}

extension type Fixed(Decimal _decimal) implements Decimal {
  static int defaultPrecision = 12;

  static final Fixed zero = Fixed(Decimal.zero);
  static final Fixed one = Fixed(Decimal.one);
  static final Fixed hundred = Fixed.fromInt(100);

  factory Fixed.fromInt(int value) => Fixed(Decimal.fromInt(value));
  static Fixed parse(String value) => Fixed(Decimal.parse(value));
  factory Fixed.fromJson(String value) => Fixed.parse(value);

  static T max<T extends Decimal>(T a, T b) => a > b ? a : b;

  static T min<T extends Decimal>(T a, T b) => a > b ? b : a;

  Fixed log(int exponent) =>
      math_lib.pow(toDouble(), (Fixed.one / Fixed.fromInt(exponent)).toDouble()).toFixed();

  @redeclare
  Fixed operator -() => Fixed(-_decimal);

  @redeclare
  Fixed operator +(Fixed other) => Fixed(_decimal + other._decimal);

  @redeclare
  Fixed operator -(Fixed other) => Fixed(_decimal - other._decimal);

  @redeclare
  Fixed operator *(Fixed other) => Fixed(_decimal * other._decimal);

  @redeclare
  Fixed operator /(Fixed other) => Fixed((_decimal / other._decimal).toFixedDecimal());

  Decimal toDecimal() => _decimal;

  double toDouble() {
    final value = _decimal.toDouble();
    if (value.isFinite) return value;
    return round(scale: 12).toDouble();
  }

  String toJson() => _decimal.toJson();
}

extension ToFixedIntExtension on int {
  Fixed toFixed() => Fixed.fromInt(this);
}

extension IterableFixedExtensions on Iterable<Fixed> {
  Fixed get sum => fold(Fixed.zero, (sum, e) => sum + e);
}

// extension IterableExtensions on Iterable<Rational> {
//   Rational get sum => fold(Rational.zero, (sum, e) => sum + e);
//
//   Rational get average {
//     var result = Rational.zero;
//     var count = Rational.zero;
//     for (final value in this) {
//       count += Rational.one;
//       result += (value - result) / count;
//     }
//     return result;
//   }
// }
