import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mek/mek.dart';
import 'package:reactive_forms/reactive_forms.dart';

typedef FieldViewBuilder<T extends Object> =
    Widget Function(BuildContext context, TypeAheadConfig<T> field);

class TypeAheadConfig<T extends Object> {
  final T? value;
  final bool enabled;
  final String? errorText;

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function() _onSubmitted;

  void onSubmitted(String _) => _onSubmitted();

  void submit() => _onSubmitted();

  const TypeAheadConfig({
    required this.value,
    required this.enabled,
    required this.errorText,
    required this.controller,
    required this.focusNode,
    required void Function() onSubmitted,
  }) : _onSubmitted = onSubmitted;
}

// , ViewValue extends Object
class ReactiveTypeAheadField<T extends Object> extends ReactiveFormField<T, T> {
  final TextEditingController? controller;
  // final TextFieldBuilder builder;
  // final void Function(ReactiveTypeAheadFieldState field, T suggestion) onSelected;
  final AutocompleteOptionToString<T> displayStringForOption;

  ReactiveTypeAheadField({
    super.key,
    required FormControl<T> super.formControl,
    required this.displayStringForOption,
    this.controller,
    required FutureOr<Iterable<T>> Function(String text) optionsBuilder,
    required FieldViewBuilder<T> fieldViewBuilder,
  }) : super(
         // valueAccessor: MekAccessors.delegate(toView: displayStringForOption, toModel: (_) => null),
         builder: (field) {
           field as ReactiveTypeAheadFieldState<T>;

           return Autocomplete<T>(
             optionsBuilder: (value) => optionsBuilder(value.text),
             onSelected: field.didChange,
             textEditingController: field.controller,
             focusNode: field.focusNode,
             displayStringForOption: displayStringForOption,
             fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
               final config = TypeAheadConfig<T>(
                 value: field.value,
                 enabled: field.control.enabled,
                 errorText: field.errorText,
                 controller: controller,
                 focusNode: focusNode,
                 onSubmitted: onSubmitted,
               );
               return fieldViewBuilder(context, config);
               // return TextField(
               //   controller: controller,
               //   focusNode: focusNode,
               //   onSubmitted: (_) => onSubmitted(),
               // );
             },
           );
         },
       );

  // static Widget _buildDecoration(BuildContext context, Widget child) {
  //   return Material(
  //     elevation: 8.0,
  //     borderRadius: const BorderRadius.all(Radius.circular(2.0)),
  //     child: child,
  //   );
  // }

  @override
  ReactiveFormFieldState<T, T> createState() => ReactiveTypeAheadFieldState();
}

class ReactiveTypeAheadFieldState<T extends Object> extends ReactiveFocusableFormFieldState<T, T> {
  late TextEditingController _textController;
  // late SuggestionsController<T> _suggestionsController;

  @override
  ReactiveTypeAheadField<T> get widget => super.widget as ReactiveTypeAheadField<T>;

  TextEditingController get controller => _textController;

  String get initialText {
    final value = this.value;
    if (value == null) return '';
    return widget.displayStringForOption(value);
  }

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController(text: initialText);
    // _suggestionsController = widget.suggestionsController ?? SuggestionsController();
  }

  @override
  void didUpdateWidget(covariant ReactiveTypeAheadField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) _textController.dispose();
      _textController = widget.controller ?? TextEditingController(text: initialText);
    }
    // if (widget.suggestionsController != oldWidget.suggestionsController) {
    //   if (oldWidget.controller == null) _textController.dispose();
    //   _suggestionsController = widget.suggestionsController ?? SuggestionsController();
    // }
  }

  @override
  void dispose() {
    if (widget.controller == null) _textController.dispose();
    // if (widget.suggestionsController == null) _suggestionsController.dispose();
    super.dispose();
  }

  @override
  void onControlValueChanged(Object? value) {
    super.onControlValueChanged(value);
    _textController.text = initialText;
  }

  // void _onSelect(T suggestion) {
  //   // _suggestionsController.close();
  //   // widget.onSelected(this, suggestion);
  // }

  void _onClear() {
    controller.clear();
    control.reset();
    control.focus();
  }

  InputDecoration get decoration => InputDecoration(
    suffixIcon: ReactiveClearButton(onClear: _onClear),
    errorText: errorText,
  );

  // Widget _build(BuildContext context, TextEditingController _, FocusNode __) =>
  //     widget.builder(context, this);
}

class TypeAheadOptionsView<T extends Object> extends StatelessWidget {
  const TypeAheadOptionsView({
    super.key,
    required this.optionBuilder,
    required this.onSelected,
    this.openDirection = OptionsViewOpenDirection.down,
    required this.options,
    this.optionsMaxHeight = 200.0,
  });

  final Widget Function(BuildContext context, T value) optionBuilder;
  final AutocompleteOnSelected<T> onSelected;
  final OptionsViewOpenDirection openDirection;
  final Iterable<T> options;
  final double optionsMaxHeight;

  @override
  Widget build(BuildContext context) {
    final highlightedIndex = AutocompleteHighlightedOption.of(context);

    final optionsAlignment = switch (openDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down => AlignmentDirectional.topStart,
    };

    return Align(
      alignment: optionsAlignment,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: optionsMaxHeight),
          child: _AutocompleteOptionsList<T>(
            optionBuilder: optionBuilder,
            highlightedIndex: highlightedIndex,
            onSelected: onSelected,
            options: options,
          ),
        ),
      ),
    );
  }
}

class _AutocompleteOptionsList<T extends Object> extends StatefulWidget {
  const _AutocompleteOptionsList({
    required this.optionBuilder,
    required this.highlightedIndex,
    required this.onSelected,
    required this.options,
  });

  final Widget Function(BuildContext context, T value) optionBuilder;
  final int highlightedIndex;
  final AutocompleteOnSelected<T> onSelected;
  final Iterable<T> options;

  @override
  State<_AutocompleteOptionsList<T>> createState() => _AutocompleteOptionsListState<T>();
}

class _AutocompleteOptionsListState<T extends Object> extends State<_AutocompleteOptionsList<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_AutocompleteOptionsList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.highlightedIndex != oldWidget.highlightedIndex) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        if (!mounted) {
          return;
        }
        final highlightedContext = GlobalObjectKey(
          widget.options.elementAt(widget.highlightedIndex),
        ).currentContext;
        if (highlightedContext == null) {
          _scrollController.jumpTo(
            widget.highlightedIndex == 0 ? 0.0 : _scrollController.position.maxScrollExtent,
          );
        } else {
          unawaited(Scrollable.ensureVisible(highlightedContext, alignment: 0.5));
        }
      }, debugLabel: 'AutocompleteOptions.ensureVisible');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlightedIndex = AutocompleteHighlightedOption.of(context);

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      controller: _scrollController,
      itemCount: widget.options.length,
      itemBuilder: (BuildContext context, int index) {
        final option = widget.options.elementAt(index);
        return InkWell(
          key: GlobalObjectKey(option),
          onTap: () => widget.onSelected(option),
          child: Builder(
            builder: (BuildContext context) {
              final highlight = highlightedIndex == index;
              return ColoredBox(
                color: highlight ? Theme.of(context).focusColor : Colors.transparent,
                child: widget.optionBuilder(context, option),
              );
            },
          ),
        );
      },
    );
  }
}
