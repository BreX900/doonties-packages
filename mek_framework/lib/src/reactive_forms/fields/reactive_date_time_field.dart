import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mek/src/form/date_time_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ReactiveDateTimeField extends ReactiveTappableField<DateTime> {
  ReactiveDateTimeField({
    super.key,
    required super.formControl,
    DateFormat? format,
    Future<DateTime?> Function(BuildContext context, DateTime value)? picker,
    super.decoration,
    DateTime? initialDate,
  }) : super(
         onTap: (context, value) async {
           final initialValue = value ?? initialDate ?? DateTime.now();

           return await (picker ?? const DateTimePicker().call)(context, initialValue);
         },
         builder: (context, value) {
           if (value == null) return const Text('');

           format ??= DateFormat(null, Localizations.localeOf(context).languageCode);
           return Text(format!.format(value));
         },
       );
}

class ReactiveTappableField<T> extends ReactiveFocusableFormField<T, T> {
  ReactiveTappableField({
    super.key,
    required FormControl<T> super.formControl,
    required Future<T?> Function(BuildContext context, T? value) onTap,
    InputDecoration decoration = const InputDecoration(),
    required Widget Function(BuildContext context, T? value) builder,
  }) : super(
         builder: (fieldState) {
           fieldState as _ReactiveTappableFieldState<T>;

           final value = fieldState.value;
           final theme = Theme.of(fieldState.context);
           final decorationTheme = theme.inputDecorationTheme;

           return MouseRegion(
             onEnter: (_) => fieldState.isHovering = true,
             onExit: (_) => fieldState.isHovering = false,
             child: InkWell(
               onTap: () async {
                 final result = await onTap(fieldState.context, value);
                 if (result == null || !fieldState.mounted) return;

                 fieldState.didChange(result);
               },
               focusNode: fieldState.focusNode,
               customBorder: decoration.border ?? decorationTheme.border,
               child: InputDecorator(
                 isHovering: fieldState.isHovering,
                 isEmpty: fieldState.value == null,
                 isFocused: fieldState.control.hasFocus,
                 decoration: decoration.copyWith(
                   enabled: fieldState.control.enabled,
                   errorText: fieldState.errorText,
                 ),
                 child: DefaultTextStyle.merge(
                   style: TextStyle(
                     color: fieldState.control.disabled ? theme.disabledColor : null,
                   ),
                   child: builder(fieldState.context, value),
                 ),
               ),
             ),
           );
         },
       );

  @override
  ReactiveFormFieldState<T, T> createState() => _ReactiveTappableFieldState();
}

class _ReactiveTappableFieldState<T> extends ReactiveFocusableFormFieldState<T, T> {
  var _isHovering = false;

  bool get isHovering => _isHovering;
  set isHovering(bool value) => setState(() => _isHovering = value);
}

// class ReactiveTappableField extends StatefulWidget {
//   final FormControl<Object> formControl;
//   final VoidCallback? onTap;
//   final FocusNode? focusNode;
//   final bool isEmpty;
//   final InputDecoration decoration;
//   final Widget child;
//
//   const ReactiveTappableField({
//     super.key,
//     required this.formControl,
//     required this.onTap,
//     required this.focusNode,
//     required this.isEmpty,
//     required this.isFocused,
//     required this.decoration,
//     required this.child,
//   });
//
//   @override
//   State<ReactiveTappableField> createState() => _ReactiveTappableFieldState();
// }
//
// class _ReactiveTappableFieldState extends State<ReactiveTappableField> {
//   var _isHovering = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final decorationTheme = Theme.of(context).inputDecorationTheme;
//
//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovering = true),
//       onExit: (_) => setState(() => _isHovering = false),
//       child: InkWell(
//         onTap: widget.onTap,
//         focusNode: widget.focusNode,
//         customBorder: widget.decoration.border ?? decorationTheme.border,
//         child: InputDecorator(
//           isHovering: _isHovering,
//           isEmpty: widget.isEmpty,
//           isFocused: widget.formControl,
//           decoration: widget.decoration,
//           child: widget.child,
//         ),
//       ),
//     );
//   }
// }
