import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';
import 'package:mek/src/form/shared/text_field_type_data.dart';
import 'package:mek/src/riverpod/adapters/state_stremable_provider.dart';
import 'package:mek/src/shared/handle_callback.dart';

class FieldText<T> extends FieldBuilder<T> {
  final FieldConvert<T?> converter;
  final TextFieldType type;
  final bool? readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final InputDecoration decoration;

  final EdgeInsetsGeometry? padding;

  const FieldText({
    super.key,
    required super.fieldBloc,
    required this.converter,
    super.focusNode,
    super.errorTranslator,
    super.enabled,
    this.type = TextFieldType.none,
    this.readOnly,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onEditingComplete,
    this.keyboardType,
    this.textAlign = TextAlign.start,
    this.style,
    this.textCapitalization = TextCapitalization.none,
    this.decoration = const InputDecoration(),
    this.padding,
  });

  const FieldText.from({
    super.key,
    required super.value,
    required this.converter,
    super.enabled,
    this.type = TextFieldType.none,
    this.textAlign = TextAlign.start,
    this.style,
    this.decoration = const InputDecoration(),
    this.padding,
  })  : readOnly = true,
        maxLines = 1,
        minLines = null,
        keyboardType = null,
        maxLength = null,
        onEditingComplete = null,
        inputFormatters = null,
        textCapitalization = TextCapitalization.none,
        super.from();

  static void update(BuildContext context, TextFieldTypeData data) {
    context.findAncestorStateOfType<_FieldTextState<Object?>>()!.update(data);
  }

  TextFieldTypeData get _data {
    return TextFieldTypeData(
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
    );
  }

  @override
  State<FieldText<T>> createState() => _FieldTextState();
}

class _FieldTextState<T> extends FieldBuilderState<FieldText<T>, T> {
  late TextEditingController _controller;
  late TextFieldTypeData _typeData;

  TextEditingController get controller => _controller;

  @override
  void initState() {
    super.initState();
    watchHasFocus();
    _controller = TextEditingController(
      text: widget.converter.toText(fieldBloc.state.value),
    );
    _typeData = widget.type.initData(context, widget._data);
  }

  @override
  void didUpdateWidget(covariant FieldText<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fieldBloc != oldWidget.fieldBloc) {
      _controller = TextEditingController(
        text: widget.converter.toText(fieldBloc.state.value),
      );
    }
    if (widget.type != oldWidget.type) {
      _typeData = widget.type.initData(context, widget._data);
    }
    if (widget.readOnly != oldWidget.readOnly) {
      _typeData = _typeData.copyWith(readOnly: widget.readOnly);
    }
    if (widget.keyboardType != oldWidget.keyboardType) {
      _typeData = _typeData.copyWith(keyboardType: widget.keyboardType);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void onFocusNodeChanged() {
    final fieldBloc = widget.fieldBloc;
    if (fieldBloc == null) return;
    _fixText(fieldBloc.state.value);
  }

  @override
  void onState(FieldBlocStateBase<T> state) {
    super.onState(state);
    final value = widget.converter.toValue(_controller.text);
    if (value == state.value) return;
    _fixText(state.value);
  }

  void update(TextFieldTypeData data) {
    if (_typeData == data) return;
    setState(() => _typeData = data);
  }

  void _changeText(String text) {
    final value = widget.converter.toValue(text);
    if (value is T) fieldBloc.changeValue(value);
  }

  void _fixText(T? value) {
    final text = widget.converter.toText(value);
    if (_controller.text == text) return;
    _controller.text = text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BuiltFormTheme.of(context);

    final field = Builder(builder: (context) {
      final isEnabled = this.isEnabled;
      final typeData = widget.type.buildData(context, _typeData);
      final decoration = widget.type.buildDecoration(context, widget.decoration);

      return TextField(
        controller: _controller,
        focusNode: focusNode,
        enabled: isEnabled,
        readOnly: typeData.readOnly,
        onChanged: _changeText,
        onEditingComplete: widget.onEditingComplete ?? completeEditing,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        textAlign: widget.textAlign,
        style: widget.style,
        decoration: decorate(decoration, isEnabled: isEnabled),
        obscureText: typeData.obscureText,
        enableSuggestions: typeData.enableSuggestions,
        autocorrect: typeData.autocorrect,
        keyboardType: typeData.keyboardType,
        inputFormatters: widget.inputFormatters ?? typeData.inputFormatters,
        textCapitalization: widget.textCapitalization,
        // textInputAction: nextFocusNode != null ? TextInputAction.next : null,
      );
    });

    return theme.wrap(
      padding: widget.padding,
      child: TextFieldScope(
        fieldBloc: widget.fieldBloc,
        decoration: widget.decoration,
        typeData: _typeData,
        child: field,
      ),
    );
  }
}

abstract class FieldConvert<T> {
  const FieldConvert();

  T? toValue(String text);

  String toText(T? value);

  static FieldConvert<T> from<T>(
    String Function(T? value) toText,
    T? Function(String text) toValue,
  ) {
    return _FieldConverter(toText, toValue);
  }

  static const FieldConvert<String> text = _TextFieldConverter();
  static const FieldConvert<int> integer = _IntFieldConvert();
  static FieldConvert<Decimal> decimal(DecimalFormatter format) => _DecimalFieldConvert(format);
  static FieldConvert<Decimal> decimalFrom(
          {required Locale locale, int minimumFractionDigits = 2}) =>
      _DecimalFieldConvert.from(locale: locale, minimumFractionDigits: minimumFractionDigits);
}

abstract class TextFieldType {
  const TextFieldType();

  static const TextFieldType none = _NoneTextFieldType();

  const factory TextFieldType.integer({bool signed}) = _NumericTextFieldType.integer;
  const factory TextFieldType.decimal({bool signed}) = _NumericTextFieldType.decimal;
  const factory TextFieldType.email() = _EmailTextFieldType;
  const factory TextFieldType.password() = _PasswordTextFieldType;
  const factory TextFieldType.secret() = _SecretTextFieldType;
  const factory TextFieldType.phoneNumber() = _PhoneNumberTextFieldType;

  TextFieldTypeData initData(BuildContext context, TextFieldTypeData data) => data;

  TextFieldTypeData buildData(BuildContext context, TextFieldTypeData data) => data;

  InputDecoration buildDecoration(BuildContext context, InputDecoration decoration) => decoration;
}

class TextFieldScope extends InheritedWidget {
  final FieldBlocRule<Object?>? fieldBloc;
  final InputDecoration decoration;
  final TextFieldTypeData typeData;

  const TextFieldScope({
    super.key,
    required this.fieldBloc,
    required this.decoration,
    required this.typeData,
    required super.child,
  });

  static TextFieldScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TextFieldScope>();
  }

  static TextFieldScope of(BuildContext context) => maybeOf(context)!;

  @override
  bool updateShouldNotify(TextFieldScope oldWidget) {
    return fieldBloc != oldWidget.fieldBloc ||
        decoration != oldWidget.decoration ||
        typeData != oldWidget.typeData;
  }
}

class _FieldConverter<T> extends FieldConvert<T> {
  final String Function(T? value) _toText;
  final T? Function(String text) _toValue;

  const _FieldConverter(this._toText, this._toValue);

  @override
  String toText(T? value) => _toText(value);

  @override
  T? toValue(String text) => _toValue(text);
}

class _TextFieldConverter extends FieldConvert<String> {
  const _TextFieldConverter();

  @override
  String? toValue(String text) => text;

  @override
  String toText(String? value) => value ?? '';
}

class _IntFieldConvert extends FieldConvert<int> {
  const _IntFieldConvert();

  @override
  int? toValue(String text) => int.tryParse(text);

  @override
  String toText(int? value) => value?.toString() ?? '';
}

class _DecimalFieldConvert extends FieldConvert<Decimal> {
  final DecimalFormatter _format;

  _DecimalFieldConvert(this._format);

  _DecimalFieldConvert.from({
    required Locale locale,
    int minimumFractionDigits = 2,
  }) : _format = DecimalFormatter(NumberFormat.decimalPattern(locale.languageCode)
          ..minimumFractionDigits = minimumFractionDigits);

  @override
  Decimal? toValue(String text) {
    if (text.isEmpty) return null;
    return _format.parse(text);
  }

  @override
  String toText(Decimal? value) => value != null ? _format.format(value) : '';
}

class _NoneTextFieldType extends TextFieldType {
  const _NoneTextFieldType();
}

class _NumericTextFieldType extends TextFieldType {
  final bool signed;
  final bool decimal;

  const _NumericTextFieldType.integer({this.signed = false}) : decimal = false;

  const _NumericTextFieldType.decimal({this.signed = false}) : decimal = true;

  @override
  TextFieldTypeData buildData(BuildContext context, TextFieldTypeData data) {
    final locale = Localizations.localeOf(context);

    return data.copyWith(
      keyboardType: TextInputType.numberWithOptions(signed: signed, decimal: decimal),
      inputFormatters: [
        _NumericTextInputFormatter(
          languageCode: locale.languageCode,
          signed: signed,
          decimal: decimal,
        )
      ],
    );
  }
}

class _NumericTextInputFormatter implements TextInputFormatter {
  final String languageCode;
  final bool signed;
  final bool decimal;

  const _NumericTextInputFormatter({
    required this.languageCode,
    this.signed = false,
    this.decimal = false,
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final format = NumberFormat.decimalPattern(languageCode);
    final symbols = format.symbols;
    final separatorOffset = newValue.text.indexOf(symbols.DECIMAL_SEP);

    var whole = separatorOffset != -1 ? newValue.text.substring(0, separatorOffset) : newValue.text;
    whole = whole.replaceAll(symbols.GROUP_SEP, '');

    final buffer = [whole.substring(max(whole.length - 3, 0))];
    for (var i = whole.length - 3; i > 0; i -= 3) {
      buffer.insert(0, symbols.GROUP_SEP);
      buffer.insert(0, whole.substring(max(i - 3, 0), i));
    }

    if (decimal && separatorOffset != -1) {
      buffer.add(symbols.DECIMAL_SEP);

      var dividend = separatorOffset != -1 ? newValue.text.substring(separatorOffset + 1) : '';
      dividend = dividend.replaceAll(symbols.GROUP_SEP, '');

      buffer.add(dividend.substring(0, min(dividend.length, 3)));
      for (var i = 3; i < dividend.length; i += 3) {
        buffer.add(symbols.GROUP_SEP);
        buffer.add(dividend.substring(i, min(dividend.length, i + 3)));
      }
    }

    final text = buffer.join();
    return TextEditingValue(
      text: text,
      selection: text.length == newValue.text.length
          ? newValue.selection
          : text.length - 1 == newValue.text.length
              ? TextSelection.collapsed(offset: newValue.selection.baseOffset + 1)
              : text.length + 1 == newValue.text.length
                  ? TextSelection.collapsed(offset: newValue.selection.baseOffset - 1)
                  : TextSelection.collapsed(offset: text.length),
    );
  }
}

class _EmailTextFieldType extends TextFieldType {
  const _EmailTextFieldType();

  @override
  TextFieldTypeData initData(BuildContext context, TextFieldTypeData data) {
    return data.copyWith(
      inputFormatters: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.deny(' ')
      ],
    );
  }
}

class _PasswordTextFieldType extends TextFieldType {
  const _PasswordTextFieldType();

  @override
  TextFieldTypeData initData(BuildContext context, TextFieldTypeData data) {
    return data.copyWith(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.deny(' ')
      ],
    );
  }

  @override
  InputDecoration buildDecoration(BuildContext context, InputDecoration decoration) {
    return decoration.copyWith(
      suffixIcon: const ShowFieldButton(),
    );
  }
}

class _SecretTextFieldType extends TextFieldType {
  const _SecretTextFieldType();

  @override
  TextFieldTypeData initData(BuildContext context, TextFieldTypeData data) {
    return data.copyWith(
      readOnly: true,
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      inputFormatters: [
        FilteringTextInputFormatter.singleLineFormatter,
        FilteringTextInputFormatter.deny(' ')
      ],
    );
  }
}

class _PhoneNumberTextFieldType extends TextFieldType {
  const _PhoneNumberTextFieldType();

  @override
  TextFieldTypeData initData(BuildContext context, TextFieldTypeData data) {
    return data.copyWith(
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[+\d ]'))],
    );
  }
}

class ShowFieldButton extends StatelessWidget {
  const ShowFieldButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = TextFieldScope.of(context);
    final typeData = scope.typeData;

    return IconButton(
      onPressed: () => FieldText.update(
          context,
          typeData.copyWith(
            obscureText: !typeData.obscureText,
          )),
      icon: typeData.obscureText ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
    );
  }
}

class EditFieldButton extends ConsumerWidget {
  final bool toggleableObscureText;
  final VoidCallback? onSubmit;

  const EditFieldButton({
    super.key,
    this.toggleableObscureText = false,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSubmit = this.onSubmit;
    final scope = TextFieldScope.of(context);
    final typeData = scope.typeData;

    // ignore: deprecated_member_use_from_same_package
    final isValid = ref.watchCanSubmit(scope.fieldBloc!);

    return IconButton(
      onPressed: typeData.readOnly
          ? () => FieldText.update(
              context,
              typeData.copyWith(
                readOnly: !typeData.readOnly,
                obscureText: toggleableObscureText ? !typeData.obscureText : null,
              ))
          : ((onSubmit != null && isValid)
              ? () async {
                  FieldText.update(
                      context,
                      typeData.copyWith(
                        readOnly: !typeData.readOnly,
                        obscureText: toggleableObscureText ? !typeData.obscureText : null,
                      ));
                  onSubmit();
                }
              : null),
      icon: typeData.readOnly ? const Icon(Icons.edit_outlined) : const Icon(Icons.check),
    );
  }
}

class SaveFieldButton extends ConsumerWidget {
  final FieldBloc<Object?> fieldBloc;
  final VoidCallback? onSubmit;

  const SaveFieldButton({
    super.key,
    required this.fieldBloc,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSubmit = this.onSubmit;

    final hasUpdatedValue = ref.watch(fieldBloc.select((state) => state.hasUpdatedValue));
    if (hasUpdatedValue) return const SizedBox.shrink();

    // ignore: deprecated_member_use_from_same_package
    final isValid = ref.watchCanSubmit(shouldHasNotUpdatedValue: false, fieldBloc);

    return IconButton(
      onPressed: isValid ? onSubmit : null,
      icon: const Icon(Icons.save),
    );
  }
}

class ClearFieldButton extends StatelessWidget {
  final bool disableOnReadOnly;

  const ClearFieldButton({
    super.key,
    this.disableOnReadOnly = true,
  });

  (FieldBlocRule?, bool) _of(BuildContext context) {
    final scope = TextFieldScope.maybeOf(context);
    if (scope != null) {
      return (scope.fieldBloc, scope.typeData.readOnly);
    }
    final state = context.findAncestorStateOfType<FieldBuilderState>()!;
    return (state.fieldBloc, false);
  }

  @override
  Widget build(BuildContext context) {
    final data = _of(context);
    final isEnabled = !(disableOnReadOnly && data.$2);

    return IconButton(
      onPressed: isEnabled ? () => data.$1!.clear(shouldUpdate: false) : null,
      icon: const Icon(Icons.clear),
    );
  }
}
