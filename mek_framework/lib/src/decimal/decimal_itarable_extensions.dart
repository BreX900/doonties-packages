import 'package:decimal/decimal.dart';

extension DecimalIterableExtensions on Iterable<Decimal> {
  Decimal get sum => fold(Decimal.zero, (sum, e) => sum + e);
}
