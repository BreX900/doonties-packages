import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';
import 'package:reactive_forms/reactive_forms.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignUpPressed;
  final Widget? footer;

  const SignInScreen({
    super.key,
    required this.onSignUpPressed,
    this.footer,
  });

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailFb = FormControlTyped<String>(
    initialValue: UserAuthProviders.debug.email,
    validators: [ValidatorsTyped.required(), ValidatorsTyped.email()],
  );
  final _passwordFb = FormControlTyped<String>(
    initialValue: UserAuthProviders.debug.password,
    validators: [ValidatorsTyped.required()],
  );

  late final _form = FormArray([_emailFb, _passwordFb]);

  late final _signIn = ref.mutation((ref, Nil _) async {
    await UserAuthProviders.signIn(
      email: _emailFb.value,
      password: _passwordFb.value,
    );
  });

  late final _sendPasswordResetEmail = ref.mutation((ref, Nil _) async {
    await UserAuthProviders.sendPasswordResetEmail(_emailFb.value);
  }, onSuccess: (_, __) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Sent password reset email to ${_emailFb.value}!'),
    ));
  });

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = !ref.watchIsMutating([_signIn, _sendPasswordResetEmail]);

    final signIn = _form.handleSubmit(_signIn.run, keepDisabled: true);
    final sendPasswordResetEmail = _emailFb.handleSubmit(_sendPasswordResetEmail.run);

    List<Widget> buildFields() {
      return [
        ReactiveTypedTextField(
          formControl: _emailFb,
          type: const TextFieldType.email(),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        ReactiveTypedTextField(
          formControl: _passwordFb,
          type: const TextFieldType.password(),
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        TextButton.icon(
          onPressed: isIdle ? () => sendPasswordResetEmail(nil) : null,
          icon: const Icon(Icons.lock_reset_outlined),
          label: const Text('Send reset password email'),
        ),
      ];
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...buildFields(),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: isIdle ? () => signIn(nil) : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
                const SizedBox(height: 16.0),
                OutlinedButton.icon(
                  onPressed: isIdle ? widget.onSignUpPressed : null,
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Sign Up'),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
            const Spacer(),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );

    return SkeletonForm(
      onSubmit: isIdle ? () => signIn(nil) : null,
      child: scaffold,
    );
  }
}
