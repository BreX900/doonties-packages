import 'package:flutter/material.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';
import 'package:mekfire/src/widgets/_confirmable_dialog.dart';

class SignOutIconButton extends StatelessWidget {
  const SignOutIconButton({super.key});

  static Future<void> signOut(BuildContext context) async {
    final canSignOut = await showTypedDialog(
      context: context,
      child: const ConfirmableDialog(
        title: Text('Sign-out?'),
        positive: Text('Sign-out'),
      ),
    );
    if (!canSignOut) return;
    await UserAuthProviders.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async => signOut(context),
      icon: const Icon(Icons.logout),
    );
  }
}
