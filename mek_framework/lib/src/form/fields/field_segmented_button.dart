import 'package:flutter/material.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek/src/form/fields/field_builder.dart';
import 'package:mek/src/form/shared/built_form_theme.dart';

abstract class FieldConverter<TBlocValue, TVIewValue> {
  const FieldConverter();

  TVIewValue convertForView(TBlocValue blocValue);

  TBlocValue convertForBloc(TVIewValue viewValue);
}

// class _FieldConverter<T> extends FieldConverter<dynamic, T> {
//   const _FieldConverter();
//
//   @override
//   // ignore: avoid_annotating_with_dynamic
//   T convertForView(dynamic blocValue) => blocValue;
//
//   @override
//   dynamic convertForBloc(T viewValue) => viewValue;
// }

class DefaultFieldConverter<T> extends FieldConverter<T, T> {
  const DefaultFieldConverter();

  @override
  T convertForView(T blocValue) => blocValue;

  @override
  T convertForBloc(T viewValue) => viewValue;
}

class SetFieldConverter<T> extends FieldConverter<T, Set<T>> {
  final bool emptyIfNull;

  const SetFieldConverter({this.emptyIfNull = false});

  @override
  Set<T> convertForView(T blocValue) => blocValue == null && emptyIfNull ? {} : {blocValue};

  @override
  T convertForBloc(Set<T> viewValue) => viewValue.singleOrNull as T;
}

extension X<T> on FieldBlocRule<T> {
  FieldConverter<T, R> transform<R>(FieldConverter<T, R> converter) => converter;
}

class FieldSegmentedButton<T> extends FieldBuilder<dynamic> with InlineFieldBuilder {
  final FieldConverter<dynamic, Set<T>> converter;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final bool showSelectedIcon;
  final InputDecoration decoration;
  final List<ButtonSegment<T>> segments;

  const FieldSegmentedButton({
    super.key,
    required super.fieldBloc,
    super.focusNode,
    required this.converter,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.showSelectedIcon = true,
    this.decoration = FieldBuilder.decorationFlat,
    required this.segments,
  });

  @override
  Widget build(BuildContext context, InlineFieldBuilderState<dynamic> state) {
    final theme = BuiltFormTheme.of(context);
    final hasFocus = state.watchHasFocus();
    final isEnabled = state.isEnabled;

    void changeValue(Set<T> value) {
      state.fieldBloc.changeValue(converter.convertForBloc(value));
    }

    final child = InputDecorator(
      isFocused: hasFocus,
      decoration: state.decorate(decoration, isEnabled: isEnabled),
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: SegmentedButton<T>(
          // TODO: focusNode: state.focusNode,
          multiSelectionEnabled: multiSelectionEnabled,
          emptySelectionAllowed: emptySelectionAllowed,
          showSelectedIcon: showSelectedIcon,
          selected: converter.convertForView(state.value),
          onSelectionChanged: isEnabled ? changeValue : null,
          segments: segments,
        ),
      ),
    );
    return theme.wrap(child: child);
  }
}
