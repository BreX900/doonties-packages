import 'package:decimal/decimal.dart';
// ignore: depend_on_referenced_packages
import 'package:rational/rational.dart';

extension DecimalIterableExtensions on Iterable<Decimal> {
  Decimal get sum => fold(Rational.zero, (sum, e) => sum + e.toRational()).toDecimal();
}

extension RationalIterableExtensions on Iterable<Rational> {
  Rational get sum => fold(Rational.zero, (sum, e) => sum + e);

  Rational get average {
    var result = Rational.zero;
    var count = Rational.zero;
    for (final value in this) {
      count += Rational.one;
      result += (value - result) / count;
    }
    return result;
  }
}
