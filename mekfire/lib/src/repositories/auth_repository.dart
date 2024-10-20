import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mekfire/src/dto/user_auth_dto.dart';
import 'package:rxdart/rxdart.dart';

class UserAuthRepository {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  static UserAuthRepository get instance => const UserAuthRepository._();
  const UserAuthRepository._();

  static final _usersChangesController = StreamController<User?>.broadcast(sync: true);

  UserAuthDto? get currentUser => _auth.currentUser?.toDto();

  Stream<UserAuthDto?> get onChange =>
      Rx.merge([_auth.userChanges(), _usersChangesController.stream])
          .map((event) => event?.toDto());

  static void initialize() {
    WidgetsBinding.instance.removeObserver(_FirebaseAuthWidgetsBindingObserver.instance);
    unawaited(_FirebaseAuthWidgetsBindingObserver.instance
        .didChangeLocales(PlatformDispatcher.instance.locales));
    WidgetsBinding.instance.addObserver(_FirebaseAuthWidgetsBindingObserver.instance);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserAuthDto> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.toDto();
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> checkEmailVerification() async {
    await _auth.currentUser!.reload();
    _usersChangesController.add(_auth.currentUser);
  }

  Future<void> delete() async {
    await _auth.currentUser!.delete();
  }

// // TODO: Validate phoneNumber, must include a country code prefixed with plus sign ('+')
// Future<String> signInWithPhoneNumber(String phoneNumber) async {
//   if (kIsWeb) {
//     final result = await _auth.signInWithPhoneNumber(phoneNumber);
//     return result.verificationId;
//   } else {
//     final sentToken = Completer<String>();
//     await _auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: _auth.signInWithCredential,
//       verificationFailed: (exception) {
//         lg.severe(
//           'FirebaseAuth.verifyPhoneNumber.verificationFailed',
//           exception,
//           StackTrace.current,
//         );
//       },
//       codeSent: (verificationId, resendToken) {
//         sentToken.complete(verificationId);
//         lg.warning('FirebaseAuth.verifyPhoneNumber.codeSent(resendToken:$resendToken) ');
//       },
//       codeAutoRetrievalTimeout: (verificationId) {
//         lg.warning(
//             'FirebaseAuth.verifyPhoneNumber.codeAutoRetrievalTimeout(verificationId:$verificationId)');
//       },
//     );
//     return sentToken.future;
//   }
// }

// Future<UserAuthDto> confirmPhoneNumberVerification(String id, {required String code}) async {
//   final crendial = PhoneAuthProvider.credential(verificationId: id, smsCode: code);
//   final credential = await _auth.signInWithCredential(crendial);
//   return credential.user!.toDto();
// }
}

class _FirebaseAuthWidgetsBindingObserver with WidgetsBindingObserver {
  static const instance = _FirebaseAuthWidgetsBindingObserver._();

  const _FirebaseAuthWidgetsBindingObserver._();

  @override
  Future<void> didChangeLocales(List<Locale>? locales) async {
    if (locales == null || locales.isEmpty) return;
    final locale = locales.first;
    await FirebaseAuth.instance.setLanguageCode(locale.languageCode);
  }
}
