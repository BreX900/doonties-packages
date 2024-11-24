import 'package:flutter/material.dart';
import 'package:mek/mek.dart';
import 'package:mekart/mekart.dart';
import 'package:reactive_forms/reactive_forms.dart';

class MekReactiveFormConfig extends StatefulWidget {
  final Widget child;

  const MekReactiveFormConfig({super.key, required this.child});

  @override
  State<MekReactiveFormConfig> createState() => _MekReactiveFormConfigState();
}

class _MekReactiveFormConfigState extends State<MekReactiveFormConfig> {
  late Map<String, ValidationMessageFunction> _validationMessages;

  @override
  void initState() {
    super.initState();
    _validationMessages = ValidationCodes.values.map((code) {
      return MapEntry(code, (error) => _translateError(code, error));
    }).toMap();
  }

  String _translateError(String code, Object error) {
    const t = ValidationEnTranslations();
    if (error is ValidationError) return translateValidationError(error, t);
    return switch (code) {
      ValidationMessage.required => translateValidationError(const RequiredValidationError(), t),
      _ => code,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConfig(
      validationMessages: _validationMessages,
      child: widget.child,
    );
  }
}
