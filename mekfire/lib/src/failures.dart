import 'package:mek/mek.dart';

class MissingCredentialsException extends MekFailure {
  @override
  String get message => 'Authentication required!';
}

class PasswordsNotMatchException extends MekFailure {
  @override
  String get message => 'Passwords not match';
}
