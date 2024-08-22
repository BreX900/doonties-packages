import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek/src/form/validation/validation_errors.dart';
import 'package:mek/src/form/validation/validation_localizations.dart';
import 'package:mek/src/shared/skeleton_form.dart';

enum FieldStatus { enabled, readOnly, disabled }

extension FieldStatusExtensions on FieldStatus {
  bool get isEnabled => this == FieldStatus.enabled;
  bool get isReadOnly => this == FieldStatus.readOnly;
  bool get isDisabled => this == FieldStatus.disabled;
}

typedef FieldErrorTranslator = String? Function(BuildContext context, Object error);

abstract class FieldBuilder<V> extends StatefulWidget {
  static const InputDecoration decorationBorderless = InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
  );

  static const InputDecoration decorationFlat = InputDecoration(
    border: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
    isDense: true,
  );

  final FieldBlocRule<V>? fieldBloc;
  final V? value;
  final FocusNode? focusNode;
  final FieldErrorTranslator? errorTranslator;
  final bool enabled;

  const FieldBuilder({
    super.key,
    required FieldBlocRule<V> this.fieldBloc,
    required this.focusNode,
    required this.errorTranslator,
    this.enabled = true,
  }) : value = null;

  const FieldBuilder.from({
    super.key,
    required V this.value,
    this.enabled = true,
  })  : fieldBloc = null,
        focusNode = null,
        errorTranslator = null;

  @override
  State<FieldBuilder<V>> createState();
}

mixin InlineFieldBuilder<V> on FieldBuilder<V> {
  Widget build(BuildContext context, InlineFieldBuilderState<V> state);

  @override
  State<FieldBuilder<V>> createState() => InlineFieldBuilderState();
}

abstract class FieldBuilderState<W extends FieldBuilder<V>, V> extends State<W> {
  FieldBlocRule<V>? _fieldBloc;
  FieldBlocRule<V> get fieldBloc => (widget.fieldBloc ?? _fieldBloc)!;

  late StreamSubscription<void> _fieldBlocSub;

  late FieldBlocStateBase<V> _fieldBlocState;
  FieldBlocStateBase<V> get fieldBlocState => _fieldBlocState;

  bool _isWatchingFocusNode = false;
  bool _hasFocus = false;
  FocusNode? _focusNode;
  FocusNode get focusNode => (_focusNode ?? widget.focusNode)!;

  bool get isEnabled => widget.enabled && _fieldBlocState.isEnabled;
  V get value => _fieldBlocState.value;

  @override
  void initState() {
    super.initState();
    _initFocusNode();
    _initFieldBloc();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _disposeFocusNode();
      _initFocusNode();
    }
    if (widget.fieldBloc != oldWidget.fieldBloc) {
      _disposeFieldBloc();
      _initFieldBloc();
    }
    if (value != oldWidget.value) {
      _fieldBloc?.updateValue(widget.value as V);
    }
  }

  @override
  void dispose() {
    _disposeFocusNode();
    _disposeFieldBloc();
    super.dispose();
  }

  @mustCallSuper
  void onState(FieldBlocStateBase<V> state) {
    setState(() => _fieldBlocState = state);
  }

  void completeEditing() => SkeletonForm.requestNextFocusOrSubmit(context, this);

  String? stringifyError() {
    if (!_fieldBlocState.isDirty) return null;

    final error = _fieldBlocState.error;
    if (error == null) return null;

    final errorTranslator = widget.errorTranslator;
    if (errorTranslator != null) return errorTranslator(context, error);

    if (error is! ValidationError) return '$error';
    return ValidationLocalizations.translate(context, error);
  }

  InputDecoration decorate(InputDecoration decoration, {required bool isEnabled}) {
    return decoration.copyWith(
      enabled: decoration.enabled && isEnabled,
      errorText: stringifyError(),
    );
  }

  bool watchHasFocus() {
    if (!_isWatchingFocusNode) {
      _hasFocus = focusNode.hasFocus;
      focusNode.addListener(onFocusNodeChanged);
      _isWatchingFocusNode = true;
    }
    return _hasFocus;
  }

  void _initFieldBloc() {
    if (widget.fieldBloc == null) _fieldBloc = FieldBloc(initialValue: widget.value as V);
    _fieldBlocState = fieldBloc.state;
    _fieldBlocSub = fieldBloc.stream.listen(onState);
  }

  void _disposeFieldBloc() {
    unawaited(_fieldBlocSub.cancel());
    unawaited(_fieldBloc?.close());
    _fieldBloc = null;
  }

  void _initFocusNode() {
    if (widget.focusNode == null) _focusNode = FocusNode();
    if (_isWatchingFocusNode) {
      _hasFocus = focusNode.hasFocus;
      focusNode.addListener(onFocusNodeChanged);
    }
  }

  void _disposeFocusNode() {
    if (_isWatchingFocusNode) focusNode.removeListener(onFocusNodeChanged);
    _focusNode?.dispose();
    _focusNode = null;
  }

  void onFocusNodeChanged() {
    if (_hasFocus == focusNode.hasFocus) return;
    setState(() => _hasFocus = focusNode.hasFocus);
  }
}

class InlineFieldBuilderState<V> extends FieldBuilderState<InlineFieldBuilder<V>, V> {
  @override
  Widget build(BuildContext context) => widget.build(context, this);
}
