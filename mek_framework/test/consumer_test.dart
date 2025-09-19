// // ignore_for_file: avoid_print
//
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mek/src/riverpod/adapters/value_listenable_provider.dart';
//
// Widget _build({required Widget child}) {
//   return Directionality(
//     textDirection: TextDirection.rtl,
//     child: ProviderScope(
//       child: child,
//     ),
//   );
// }
//
// void main() {
//   testWidgets('ValueListenable', (tester) async {
//     final listenable = ValueNotifier(0);
//
//     await tester.pumpWidget(_build(
//       child: Consumer(builder: (context, ref, _) {
//         final value = ref.watch(listenable.provider);
//         print('Build: $value');
//         return Text('$value');
//       }),
//     ));
//
//     listenable.value += 1;
//     listenable.value += 1;
//     listenable.value += 1;
//
//     await tester.pumpAndSettle();
//
//     expect(find.text('3'), findsOneWidget);
//   });
//
//   // testWidgets('Bloc', (tester) async {
//   //   final bloc = StateBloc(0);
//   //
//   //   await tester.pumpWidget(_build(
//   //     child: Consumer(builder: (context, ref, _) {
//   //       final value = ref.watch(bloc.provider);
//   //       return Text('$value');
//   //     }),
//   //   ));
//   //
//   //   bloc.emit(bloc.state + 1);
//   //   bloc.emit(bloc.state + 1);
//   //   bloc.emit(bloc.state + 1);
//   //
//   //   await tester.pumpAndSettle();
//   //
//   //   expect(find.text('3'), findsOneWidget);
//   // });
//
//   testWidgets('Bloc Listening', (tester) async {
//     final bloc = ValueNotifier(0);
//     var c = 1;
//
//     await tester.pumpWidget(_build(
//       child: Consumer(builder: (context, ref, _) {
//         final a = c;
//         ref.listen(bloc.provider, (prev, next) {
//           print('$next Build: $a');
//         });
//         return const SizedBox.shrink();
//       }),
//     ));
//
//     bloc.value += 1;
//     c += 1;
//     bloc.value += 1;
//
//     await tester.pumpAndSettle();
//   });
// }
