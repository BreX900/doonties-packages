import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveFormFieldDecorated<T> extends ReactiveFocusableFormField<T, T> {
  ReactiveFormFieldDecorated({
    super.key,
    required FormControl<T> super.formControl,
    InputDecoration decoration = const InputDecoration(),
    required ReactiveFormFieldBuilder<T, T> builder,
  }) : super(
         builder: (field) {
           final child = builder(field);
           final styledDecoration = decoration.applyDefaults(
             const InputDecorationTheme(contentPadding: EdgeInsets.zero),
           );

           return Focus(
             focusNode: field.focusNode,
             child: InputDecorator(
               isFocused: field.focusNode?.hasFocus ?? false,
               decoration: styledDecoration.copyWith(errorText: field.errorText),
               child: child,
             ),
           );
         },
       );
}
