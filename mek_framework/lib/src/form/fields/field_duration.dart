import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:mek/src/form/fields/field_builder.dart';

class FieldDuration<T extends Duration?> extends FieldBuilder<T> with InlineFieldBuilder {
  final InputDecoration decoration;

  /// Default: [TimeOfDay.now]
  final Duration? initialTime;

  const FieldDuration({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    this.decoration = const InputDecoration(),
    this.initialTime,
  });

  Widget _buildBottomSheet(BuildContext context) {
    return CupertinoPicker(
      itemExtent: 300,
      onSelectedItemChanged: (_) {},
      children: const [],
    );
  }

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<T> state) {
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    Future<void> changeValue() async {
      final value = await showModalBottomSheet<T>(
        context: context,
        builder: _buildBottomSheet,
      );
      if (value == null) return;
      state.fieldBloc.updateValue(value);
      state.completeEditing();
    }

    return InputDecorator(
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      isEmpty: state.value == null,
      isFocused: hasFocus,
      child: InkWell(
        focusNode: state.focusNode,
        onTap: isEnabled ? changeValue : null,
        child: Text('${state.value}'),
      ),
    );
  }
}
