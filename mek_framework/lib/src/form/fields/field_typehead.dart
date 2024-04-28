import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// ignore: implementation_imports
import 'package:flutter_typeahead/src/common/base/types.dart';
// ignore: implementation_imports
import 'package:flutter_typeahead/src/common/box/suggestions_list.dart';
// ignore: implementation_imports
import 'package:flutter_typeahead/src/common/search/suggestions_search.dart';
import 'package:mek/mek.dart';

class FieldTypehead<T> extends FieldBuilder<T> {
  final InputDecoration decoration;

  final Duration debounceDuration;

  final String Function(T value) toText;

  /// [SuggestionsSearch.suggestionsCallback]
  final SuggestionsCallback<T> suggestionsCallback;

  /// [SuggestionsList.itemBuilder]
  final SuggestionsItemBuilder<T> itemBuilder;

  const FieldTypehead({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    super.errorTranslator,
    this.decoration = const InputDecoration(),
    this.debounceDuration = const Duration(milliseconds: 300),
    required this.toText,
    required this.suggestionsCallback,
    required this.itemBuilder,
  });

  @override
  State<FieldTypehead<T>> createState() => _FieldTypeheadState();
}

class _FieldTypeheadState<T> extends FieldBuilderState<FieldTypehead<T>, T> {
  late TextEditingController _controller;

  TextEditingController get controller => _controller;

  @override
  void initState() {
    super.initState();
    watchHasFocus();
    _controller = TextEditingController(
      text: widget.toText(fieldBloc.state.value),
    );
  }

  @override
  void didUpdateWidget(covariant FieldTypehead<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fieldBloc != oldWidget.fieldBloc) {
      _controller = TextEditingController(
        text: widget.toText(fieldBloc.state.value),
      );
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
    _fixText(state.value);
  }

  void _fixText(T value) {
    final text = widget.toText(value);
    if (_controller.text == text) return;
    _controller.text = text;
  }

  void _select(T value) {
    _fixText(value);
    fieldBloc.changeValue(value);
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: widget.decoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldTheme = BuiltFormTheme.of(context);

    final child = TypeAheadField<T>(
      controller: _controller,
      focusNode: focusNode,
      builder: _buildTextField,
      debounceDuration: widget.debounceDuration,
      itemBuilder: widget.itemBuilder,
      onSelected: _select,
      suggestionsCallback: widget.suggestionsCallback,
    );
    return fieldTheme.wrap(
      child: child,
    );
  }
}
