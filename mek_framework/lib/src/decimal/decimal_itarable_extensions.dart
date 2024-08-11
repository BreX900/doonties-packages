import 'package:decimal/decimal.dart';
// ignore: depend_on_referenced_packages
import 'package:rational/rational.dart';

extension DecimalIterableExtensions on Iterable<Decimal> {
  Decimal get sum => fold(Decimal.zero, (sum, e) => sum + e);

  Decimal average({
    int? scaleOnInfinitePrecision,
    BigInt Function(Rational)? toBigInt,
  }) {
    var result = Decimal.zero;
    var count = Decimal.zero;
    for (final value in this) {
      count += Decimal.one;
      result += ((value - result) / count).toDecimal(
        scaleOnInfinitePrecision: scaleOnInfinitePrecision,
        toBigInt: toBigInt,
      );
    }
    return result;
  }
}
