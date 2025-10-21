// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// // ignore: implementation_imports
// import 'package:flutter_typeahead/src/common/base/types.dart';
// import 'package:mek/src/reactive_forms/reactive_buttons.dart';
// import 'package:reactive_forms/reactive_forms.dart';
//
// typedef TextFieldBuilder = Widget Function(BuildContext context, ReactiveTypeAheadFieldState field);
//
// class ReactiveTypeAheadField<T> extends ReactiveFormField<Object?, Object?> {
//   final TextEditingController? controller;
//   final TextFieldBuilder builder;
//   final SuggestionsController<T>? suggestionsController;
//   final void Function(ReactiveTypeAheadFieldState field, T suggestion) onSelected;
//
//   ReactiveTypeAheadField({
//     super.key,
//     required FormControl<Object?> super.formControl,
//     Duration animationDuration = const Duration(milliseconds: 200),
//     bool autoFlipDirection = false,
//     double autoFlipMinHeight = 144,
//     required this.builder,
//     this.controller,
//     Duration debounceDuration = const Duration(milliseconds: 300),
//     VerticalDirection direction = VerticalDirection.down,
//     SuggestionsErrorBuilder? errorBuilder,
//     super.focusNode,
//     bool hideKeyboardOnDrag = false,
//     bool hideOnEmpty = false,
//     bool hideOnError = false,
//     bool hideOnLoading = false,
//     bool showOnFocus = true,
//     bool hideOnUnfocus = true,
//     bool hideWithKeyboard = true,
//     bool hideOnSelect = true,
//     required SuggestionsItemBuilder<T> itemBuilder,
//     IndexedWidgetBuilder? itemSeparatorBuilder,
//     bool retainOnLoading = true,
//     WidgetBuilder? loadingBuilder,
//     WidgetBuilder? emptyBuilder,
//     required this.onSelected,
//     ScrollController? scrollController,
//     this.suggestionsController,
//     required SuggestionsCallback<T> suggestionsCallback,
//     AnimationTransitionBuilder? transitionBuilder,
//     DecorationBuilder? decorationBuilder,
//     ListBuilder? listBuilder,
//     BoxConstraints? constraints,
//     Offset? offset,
//   }) : super(
//          builder: (field) {
//            field as ReactiveTypeAheadFieldState<T>;
//
//            return TypeAheadField<T>(
//              animationDuration: animationDuration,
//              autoFlipDirection: autoFlipDirection,
//              autoFlipMinHeight: autoFlipMinHeight,
//              builder: field._build,
//              controller: field.controller,
//              debounceDuration: debounceDuration,
//              direction: direction,
//              errorBuilder: errorBuilder,
//              focusNode: field.focusNode,
//              hideKeyboardOnDrag: hideKeyboardOnDrag,
//              hideOnEmpty: hideOnEmpty,
//              hideOnError: hideOnError,
//              hideOnLoading: hideOnLoading,
//              showOnFocus: showOnFocus,
//              hideOnUnfocus: hideOnUnfocus,
//              hideWithKeyboard: hideWithKeyboard,
//              hideOnSelect: hideOnSelect,
//              itemBuilder: itemBuilder,
//              itemSeparatorBuilder: itemSeparatorBuilder,
//              retainOnLoading: retainOnLoading,
//              loadingBuilder: loadingBuilder,
//              emptyBuilder: emptyBuilder,
//              onSelected: field._onSelect,
//              scrollController: scrollController,
//              suggestionsController: field._suggestionsController,
//              suggestionsCallback: suggestionsCallback,
//              transitionBuilder: transitionBuilder,
//              decorationBuilder: decorationBuilder ?? _buildDecoration,
//              listBuilder: listBuilder,
//              constraints: constraints,
//              offset: offset,
//            );
//          },
//        );
//
//   static Widget _buildDecoration(BuildContext context, Widget child) {
//     return Material(
//       elevation: 8.0,
//       borderRadius: const BorderRadius.all(Radius.circular(2.0)),
//       child: child,
//     );
//   }
//
//   @override
//   ReactiveFormFieldState<Object?, Object?> createState() => ReactiveTypeAheadFieldState<T>();
// }
//
// class ReactiveTypeAheadFieldState<T> extends ReactiveFocusableFormFieldState<Object?, Object?> {
//   late TextEditingController _textController;
//   late SuggestionsController<T> _suggestionsController;
//
//   @override
//   ReactiveTypeAheadField<T> get widget => super.widget as ReactiveTypeAheadField<T>;
//
//   TextEditingController get controller => _textController;
//
//   @override
//   void initState() {
//     super.initState();
//     _textController = widget.controller ?? TextEditingController();
//     _suggestionsController = widget.suggestionsController ?? SuggestionsController();
//   }
//
//   @override
//   void didUpdateWidget(covariant ReactiveTypeAheadField<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.controller != oldWidget.controller) {
//       if (oldWidget.controller == null) _textController.dispose();
//       _textController = widget.controller ?? TextEditingController();
//     }
//     if (widget.suggestionsController != oldWidget.suggestionsController) {
//       if (oldWidget.controller == null) _textController.dispose();
//       _suggestionsController = widget.suggestionsController ?? SuggestionsController();
//     }
//   }
//
//   @override
//   void dispose() {
//     if (widget.controller == null) _textController.dispose();
//     if (widget.suggestionsController == null) _suggestionsController.dispose();
//     super.dispose();
//   }
//
//   void _onSelect(T suggestion) {
//     _suggestionsController.close();
//     widget.onSelected(this, suggestion);
//   }
//
//   void _onClear() {
//     controller.clear();
//     control.reset();
//     control.focus();
//   }
//
//   InputDecoration get decoration => InputDecoration(
//     suffixIcon: ReactiveClearButton(onClear: _onClear),
//     errorText: errorText,
//   );
//
//   Widget _build(BuildContext context, TextEditingController _, FocusNode __) =>
//       widget.builder(context, this);
// }
