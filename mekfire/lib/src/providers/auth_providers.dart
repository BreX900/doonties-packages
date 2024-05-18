import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mekfire/src/dto/user_auth_dto.dart';
import 'package:mekfire/src/failures.dart';
import 'package:mekfire/src/repositories/auth_repository.dart';

enum SignStatus { none, unverified, verified }

final class UserAuthProviders {
  static UserAuthDto? get current => UserAuthRepository.instance.currentUser;

  static Stream<UserAuthDto?> get onCurrentChange => UserAuthRepository.instance.onChange;

  static Future<void> signIn(
    Ref ref, {
    required String email,
    required String password,
  }) async {
    await UserAuthRepository.instance.signIn(email: email, password: password);
  }

  static Future<void> sendPasswordResetEmail(Ref ref, String email) async {
    await UserAuthRepository.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signUp(
    Ref ref, {
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) throw PasswordsNotMatchException();

    await UserAuthRepository.instance.signUp(email: email, password: password);
    await UserAuthRepository.instance.sendEmailVerification();
  }

  static Future<void> sendEmailVerification(Ref ref) async {
    await UserAuthRepository.instance.sendEmailVerification();
  }

  static Future<void> checkEmailVerification(Ref ref) async {
    await UserAuthRepository.instance.checkEmailVerification();
  }

  static Future<void> signOut() async {
    await UserAuthRepository.instance.signOut();
  }

  String email = '';
  String password = '';

  UserAuthProviders._();

  static final UserAuthProviders debug = UserAuthProviders._();
}
