import 'package:firebase_auth/firebase_auth.dart';

class UserAuthDto {
  final String id;
  // final DateTime createdAt;
  final String email;
  final bool emailVerified;

  const UserAuthDto({
    required this.id,
    // required this.createdAt,
    required this.email,
    required this.emailVerified,
  });
}

extension FirebaseUserToDtoExtension on User {
  UserAuthDto toDto() {
    return UserAuthDto(
      id: uid,
      // createdAt: metadata.creationTime!,
      email: email!,
      emailVerified: emailVerified,
    );
  }
}
