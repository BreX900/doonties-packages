// return FieldMultiSearch(
//       fieldBloc: fieldBloc,
//       decoration: decoration,
//       optionsFetcher: (query) =>
//           ingredients.where((e) => e.title.toLowerCase().contains(query.toLowerCase())).toList(),
//       optionBuilder: (context, value) => Text(value.title),
//       builder: (context, options) {
//         return Wrap(
//           children: options.map((e) {
//             return Chip(
//               padding: EdgeInsets.zero,
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               label: Text(e.title),
//             );
//           }).toList(),
//         );
//       },
//     );

// import 'dart:async';
//
// import 'package:fast_immutable_collections/fast_immutable_collections.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:mek/src/form/fields/field_builder.dart';
// import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
//
// typedef OptionsResolver<T> = FutureOr<Iterable<T>> Function(String text);
// typedef OptionBuilder<T> = Widget Function(BuildContext context, T option);
// typedef OptionsBuilder<T> = Widget Function(BuildContext context, List<T> option);
//
// class FieldMultiSearch<T extends Object> extends FieldBuilder<IList<T>> with InlineFieldBuilder {
//   final InputDecoration decoration;
//   final OptionsResolver<T> optionsFetcher;
//   final OptionBuilder<T> optionBuilder;
//   final OptionsBuilder<T> builder;
//
//   const FieldMultiSearch({
//     super.key,
//     required super.fieldBloc,
//     super.focusNode,
//     this.decoration = const InputDecoration(),
//     required this.optionsFetcher,
//     this.optionBuilder = _defaultLabelBuilder,
//     required this.builder,
//   });
//
//   static Widget _defaultLabelBuilder(BuildContext context, Object? value) => Text('$value');
//
//   // Widget _buildSuggestions(BuildContext context, ValueSetter<T> select, Iterable<T> suggestions) {
//   //   return Align(
//   //     alignment: AlignmentDirectional.topStart,
//   //     child: Material(
//   //       elevation: 4.0,
//   //       child: ConstrainedBox(
//   //         constraints: const BoxConstraints(maxHeight: 200),
//   //         child: SingleChildScrollView(
//   //           child: Column(
//   //             mainAxisSize: MainAxisSize.min,
//   //             children: suggestions.map((value) {
//   //               if (suggestionBuilder != null) {
//   //                 return InkWell(
//   //                   onTap: () => select(value),
//   //                   child: suggestionBuilder!(context, value),
//   //                 );
//   //               }
//   //               return ListTile(
//   //                 onTap: () => select(value),
//   //                 title: optionBuilder(context, value),
//   //               );
//   //             }).toList(),
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//   //
//   // Widget _buildChip(BuildContext context, ChipsInputState<T> state, T value) {
//   //   if (chipBuilder != null) return chipBuilder!(context, state, value);
//   //
//   //   return Chip(
//   //     onDeleted: () => state.deleteChip(value),
//   //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//   //     padding: const EdgeInsets.only(),
//   //     label: optionBuilder(context, value),
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context, InlineFieldBuilderState<IList<T>> state) {
//     final isEnabled = state.isEnabled;
//
//     void changeValue(T value) {
//       state.fieldBloc.changeValue(state.value.add(value));
//       state.completeEditing();
//     }
//
//     // final textField = TypeAheadField<T>(
//     //   suggestionsCallback: optionsFetcher,
//     //   itemBuilder: (context, item) {
//     //     return ListTile(
//     //       // onTap: () => select(value),
//     //       title: optionBuilder(context, item),
//     //     );
//     //   },
//     //   onSuggestionSelected: changeValue,
//     // );
//     final view = builder(context, state.value.unlockView);
//
//     return IntrinsicHeight(
//       child: InputDecorator(
//         decoration: decoration.copyWith(
//           // contentPadding: EdgeInsets.only(top: 8.0, bottom: 4.0),
//           suffixIcon: IconButton(
//             onPressed: () => showDialog(
//               context: context,
//               builder: (context) => MultiSelectDialog(
//                 items: state.value.unlockView,
//                 initialValue: initialValue,
//               ),
//             ),
//             icon: const Icon(Icons.edit_outlined),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: view,
//         ),
//       ),
//     );
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Expanded(child: textField),
//         Expanded(child: view),
//       ],
//     );
//   }
// }
//
// class _Input<T extends Object> extends StatelessWidget {
//   final OptionsResolver<T> optionsFetcher;
//   final AutocompleteOptionsViewBuilder<T> optionsViewBuilder;
//   final ValueChanged<T> onSelected;
//
//   const _Input({
//     super.key,
//     required this.optionsFetcher,
//     required this.optionsViewBuilder,
//     required this.onSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return RawAutocomplete(
//       optionsViewBuilder: optionsViewBuilder,
//       // ignore: discarded_futures
//       optionsBuilder: (value) => optionsFetcher(value.text),
//       onSelected: onSelected,
//     );
//   }
// }
//
// class _SearchField<T> extends StatelessWidget {
//   final OptionsResolver<T> optionsFetcher;
//   final ItemBuilder<T> optionBuilder;
//   final SuggestionSelectionCallback<T> onSelected;
//
//   const _SearchField({
//     super.key,
//     required this.optionsFetcher,
//     required this.optionBuilder,
//     required this.onSelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TypeAheadField<T>(
//       suggestionsCallback: optionsFetcher,
//       itemBuilder: optionBuilder,
//       onSuggestionSelected: onSelected,
//     );
//   }
// }
