import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveDecoratedSlider<T extends num> extends ReactiveFocusableFormField<num, double> {
  ReactiveDecoratedSlider({
    super.key,
    super.formControlName,
    required FormControl<T> super.formControl,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    ReactiveSliderLabelBuilder? labelBuilder,
    Color? activeColor,
    Color? inactiveColor,
    Color? thumbColor,
    SemanticFormatterCallback? semanticFormatterCallback,
    bool autofocus = false,
    MouseCursor? mouseCursor,
    super.focusNode,
    ReactiveFormFieldCallback<T>? onChangeEnd,
    ReactiveFormFieldCallback<T>? onChangeStart,
    ReactiveFormFieldCallback<T>? onChanged,
    double? secondaryTrackValue,
    Color? secondaryActiveColor,
    WidgetStateProperty<Color?>? overlayColor,
    InputDecoration decoration = const InputDecoration(),
  })  : assert(decoration.contentPadding == null),
        super(
          builder: (field) {
            field as _ReactiveDecoratedSliderState;

            var value = field.value;
            if (value == null) {
              value = min;
            } else if (value < min) {
              value = min;
            } else if (value > max) {
              value = max;
            }

            final slider = Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              secondaryTrackValue: secondaryTrackValue,
              secondaryActiveColor: secondaryActiveColor,
              overlayColor: overlayColor,
              label: labelBuilder != null ? labelBuilder(field.value ?? min) : null,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              thumbColor: thumbColor,
              semanticFormatterCallback: semanticFormatterCallback,
              mouseCursor: mouseCursor,
              autofocus: autofocus,
              focusNode: field.focusNode,
              onChangeEnd:
                  onChangeEnd != null ? (_) => onChangeEnd(field.control as FormControl<T>) : null,
              onChangeStart: onChangeStart != null
                  ? (_) => onChangeStart(field.control as FormControl<T>)
                  : null,
              onChanged: field.control.enabled
                  ? (value) {
                      field.didChange(value);
                      onChanged?.call(field.control as FormControl<T>);
                    }
                  : null,
            );

            return InputDecorator(
              isFocused: field.hasFocus,
              decoration: decoration.copyWith(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 8.0),
                isDense: true,
                enabled: decoration.enabled && field.control.enabled,
                errorText: field.errorText,
              ),
              child: SizedBox(
                height: 32.0,
                child: slider,
              ),
            );
          },
        );
  @override
  ReactiveFormFieldState<num, double> createState() => _ReactiveDecoratedSliderState();
}

class _ReactiveDecoratedSliderState extends ReactiveFocusableFormFieldState<num, double> {
  late FocusNode _focusNode;
  bool get hasFocus => focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _focusNode = focusNode;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant ReactiveFormField<num, double> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode != focusNode) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode = focusNode;
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  ControlValueAccessor<num, double> selectValueAccessor() {
    if (control is FormControl<int>) return SliderIntValueAccessor();

    return super.selectValueAccessor();
  }
}
