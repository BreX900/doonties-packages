import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';
import 'package:mekart/mekart.dart';
import 'package:meta/meta.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract final class MekAccessors {
  static ControlValueAccessor<ModelDataType, ViewDataType> delegate<ModelDataType, ViewDataType>({
    required ViewDataType? Function(ModelDataType value) toView,
    required ModelDataType? Function(ViewDataType value) toModel,
  }) => _DelegateAccessor(toView: toView, toModel: toModel);

  static ControlValueAccessor<Fixed, String> decimalToString(NumberFormat format) =>
      _ControlDecimalAccessor(DecimalFormatter(format));

  static ControlValueAccessor<Fixed, String> decimalPercentToString(NumberFormat format) =>
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

class _ControlDecimalAccessor extends ControlValueAccessor<Fixed, String> {
  final DecimalFormatter format;
  final bool isPercent;

  _ControlDecimalAccessor(this.format) : isPercent = false;

  _ControlDecimalAccessor.percent(this.format) : isPercent = true;

  @override
  String? modelToViewValue(Fixed? modelValue) {
    if (modelValue == null) return null;
    return format.format(isPercent ? modelValue * Fixed.hundred : modelValue);
  }

  @override
  Fixed? viewToModelValue(String? viewValue) {
    if (viewValue == null || viewValue.isEmpty) return null;
    return isPercent
        ? (Fixed(format.parse(viewValue)) / Fixed.hundred)
        : Fixed(format.parse(viewValue));
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
