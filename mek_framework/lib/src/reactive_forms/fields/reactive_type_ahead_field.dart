import 'package:flutter/cupertino.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
// ignore: implementation_imports
import 'package:flutter_typeahead/src/common/base/types.dart';
import 'package:reactive_forms/reactive_forms.dart';

typedef TextFieldBuilder = Widget Function(BuildContext context, ReactiveTypeAheadFieldState field);

class ReactiveTypeAheadField<T> extends ReactiveFormField<Object?, Object?> {
  final TextEditingController? controller;

  ReactiveTypeAheadField({
    super.key,
    required FormControl<Object?> super.formControl,
    Duration animationDuration = const Duration(milliseconds: 200),
    bool autoFlipDirection = false,
    double autoFlipMinHeight = 144,
    TextFieldBuilder? builder,
    this.controller,
    Duration debounceDuration = const Duration(milliseconds: 300),
    VerticalDirection direction = VerticalDirection.down,
    SuggestionsErrorBuilder? errorBuilder,
    super.focusNode,
    bool hideKeyboardOnDrag = false,
    bool hideOnEmpty = false,
    bool hideOnError = false,
    bool hideOnLoading = false,
    bool showOnFocus = true,
    bool hideOnUnfocus = true,
    bool hideWithKeyboard = true,
    bool hideOnSelect = true,
    required SuggestionsItemBuilder<T> itemBuilder,
    IndexedWidgetBuilder? itemSeparatorBuilder,
    bool retainOnLoading = true,
    WidgetBuilder? loadingBuilder,
    WidgetBuilder? emptyBuilder,
    required void Function(ReactiveTypeAheadFieldState field, T suggestion) onSelected,
    ScrollController? scrollController,
    SuggestionsController<T>? suggestionsController,
    required SuggestionsCallback<T> suggestionsCallback,
    AnimationTransitionBuilder? transitionBuilder,
    DecorationBuilder? decorationBuilder,
    ListBuilder? listBuilder,
    BoxConstraints? constraints,
    Offset? offset,
  }) : super(
          builder: (field) {
            field as ReactiveTypeAheadFieldState<T>;

            return TypeAheadField<T>(
              animationDuration: animationDuration,
              autoFlipDirection: autoFlipDirection,
              autoFlipMinHeight: autoFlipMinHeight,
              builder: builder != null
                  ? (context, controller, focusNode) => builder(context, field)
                  : null,
              controller: field.controller,
              debounceDuration: debounceDuration,
              direction: direction,
              errorBuilder: errorBuilder,
              focusNode: field.focusNode,
              hideKeyboardOnDrag: hideKeyboardOnDrag,
              hideOnEmpty: hideOnEmpty,
              hideOnError: hideOnError,
              hideOnLoading: hideOnLoading,
              showOnFocus: showOnFocus,
              hideOnUnfocus: hideOnUnfocus,
              hideWithKeyboard: hideWithKeyboard,
              hideOnSelect: hideOnSelect,
              itemBuilder: itemBuilder,
              itemSeparatorBuilder: itemSeparatorBuilder,
              retainOnLoading: retainOnLoading,
              loadingBuilder: loadingBuilder,
              emptyBuilder: emptyBuilder,
              onSelected: (suggestion) => onSelected(field, suggestion),
              scrollController: scrollController,
              suggestionsController: suggestionsController,
              suggestionsCallback: suggestionsCallback,
              transitionBuilder: transitionBuilder,
              decorationBuilder: decorationBuilder,
              listBuilder: listBuilder,
              constraints: constraints,
              offset: offset,
            );
          },
        );
  @override
  ReactiveFormFieldState<Object?, Object?> createState() => ReactiveTypeAheadFieldState<T>();
}

class ReactiveTypeAheadFieldState<T> extends ReactiveFocusableFormFieldState<Object?, Object?> {
  late TextEditingController _textController;

  @override
  ReactiveTypeAheadField<T> get widget => super.widget as ReactiveTypeAheadField<T>;

  TextEditingController get controller => _textController;

  @override
  void initState() {
    super.initState();
    _initializeTextController();
  }

  @override
  void didUpdateWidget(covariant ReactiveTypeAheadField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) _textController.dispose();
      _initializeTextController();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _textController.dispose();
    super.dispose();
  }

  void _initializeTextController() {
    _textController = widget.controller ?? TextEditingController();
  }
}
