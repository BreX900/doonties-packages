// import 'dart:async';
//
// import 'package:mek/src/source/source.dart';
// import 'package:reactive_forms/reactive_forms.dart';
//
// extension LinkLifeToSourceNotifierExtension<T extends SourceNotifier> on T {
//   T linkLifeTo(ConsumerScope scope) {
//     scope.onDispose(dispose);
//     return this;
//   }
// }
//
// extension LinkLifeToAbstractControlExtension<T extends AbstractControl> on T {
//   T linkLifeTo(ConsumerScope scope) {
//     scope.onDispose(dispose);
//     return this;
//   }
// }
//
// extension LinkLifeToStreamSubscriptionExtension<T extends StreamSubscription> on T {
//   T linkLifeTo(ConsumerScope scope) {
//     scope.onDispose(cancel);
//     return this;
//   }
// }
