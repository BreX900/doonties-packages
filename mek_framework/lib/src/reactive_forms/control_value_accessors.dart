import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ControlDecimalAccessor extends ControlValueAccessor<Decimal, String> with EquatableMixin {
  final DecimalFormatter format;
  final bool isPercent;

  ControlDecimalAccessor(this.format) : isPercent = false;

  ControlDecimalAccessor.percent(this.format) : isPercent = true;

  @override
  String? modelToViewValue(Decimal? modelValue) {
    if (modelValue == null) return null;
    return format.format(isPercent ? modelValue * Decimal.fromInt(100) : modelValue);
  }

  @override
  Decimal? viewToModelValue(String? viewValue) {
    if (viewValue == null) return null;
    return isPercent
        ? (format.parse(viewValue) / Decimal.fromInt(100)).toDecimal()
        : format.parse(viewValue);
  }

  @override
  List<Object?> get props => [format, isPercent];
}

class ControlDoubleAccessor extends ControlValueAccessor<double, String> with EquatableMixin {
  final NumberFormat format;
  final bool isPercent;

  ControlDoubleAccessor(this.format) : isPercent = false;

  ControlDoubleAccessor.percent(this.format) : isPercent = true;

  @override
  String? modelToViewValue(double? modelValue) {
    if (modelValue == null) return null;
    return format.format(isPercent ? modelValue * 100.0 : modelValue);
  }

  @override
  double? viewToModelValue(String? viewValue) {
    if (viewValue == null) return null;
    return isPercent ? (format.parse(viewValue) / 100.0) : format.parse(viewValue).toDouble();
  }

  @override
  List<Object?> get props => [format, isPercent];
}
