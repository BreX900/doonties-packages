import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract final class MekAccessors {
  static ControlValueAccessor<ModelDataType, ViewDataType> delegate<ModelDataType, ViewDataType>({
    required ViewDataType? Function(ModelDataType value) toView,
    required ModelDataType? Function(ViewDataType value) toModel,
  }) => _DelegateAccessor(toView: toView, toModel: toModel);

  static ControlValueAccessor<Decimal, String> decimalToString(NumberFormat format) =>
      _ControlDecimalAccessor(DecimalFormatter(format));

  static ControlValueAccessor<Decimal, String> decimalPercentToString(NumberFormat format) =>
      _ControlDecimalAccessor.percent(DecimalFormatter(format));

  static ControlValueAccessor<double, String> doubleToString(NumberFormat format) =>
      ControlDoubleAccessor(format);

  static ControlValueAccessor<double, String> doublePercentToString(NumberFormat format) =>
      ControlDoubleAccessor.percent(format);
}

class _DelegateAccessor<ModelDataType, ViewDataType>
    extends ControlValueAccessor<ModelDataType, ViewDataType> {
  final ViewDataType? Function(ModelDataType value) toView;
  final ModelDataType? Function(ViewDataType value) toModel;

  _DelegateAccessor({required this.toView, required this.toModel});

  @override
  ViewDataType? modelToViewValue(ModelDataType? modelValue) {
    if (modelValue == null) return null;
    return toView(modelValue);
  }

  @override
  ModelDataType? viewToModelValue(ViewDataType? viewValue) {
    if (viewValue == null) return null;
    return toModel(viewValue);
  }
}

class _ControlDecimalAccessor extends ControlValueAccessor<Decimal, String> {
  final DecimalFormatter format;
  final bool isPercent;

  _ControlDecimalAccessor(this.format) : isPercent = false;

  _ControlDecimalAccessor.percent(this.format) : isPercent = true;

  @override
  String? modelToViewValue(Decimal? modelValue) {
    if (modelValue == null) return null;
    return format.format(isPercent ? modelValue * Decimal.fromInt(100) : modelValue);
  }

  @override
  Decimal? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.isEmpty) return null;
    return isPercent
        ? (format.parse(viewValue) / Decimal.fromInt(100)).toDecimal()
        : format.parse(viewValue);
  }
}

class ControlDoubleAccessor extends ControlValueAccessor<double, String> {
  final NumberFormat format;
  final bool isPercent;

  @internal
  ControlDoubleAccessor(this.format) : isPercent = false;

  @internal
  ControlDoubleAccessor.percent(this.format) : isPercent = true;

  @override
  String? modelToViewValue(double? modelValue) {
    if (modelValue == null) return null;
    return format.format(isPercent ? modelValue * 100.0 : modelValue);
  }

  @override
  double? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.isEmpty) return null;
    return isPercent ? (format.parse(viewValue) / 100.0) : format.parse(viewValue).toDouble();
  }
}
