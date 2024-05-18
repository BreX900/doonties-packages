import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';

class SignInScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignUpPressed;

  const SignInScreen({
    super.key,
    required this.onSignUpPressed,
  });

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailFb = FieldBloc(
    initialValue: UserAuthProviders.debug.email,
    validator: Validation.email,
  );
  final _passwordFb = FieldBloc(
    initialValue: UserAuthProviders.debug.password,
    validator: const TextValidation(minLength: 1),
  );

  final _form = ListFieldBloc<void>();

  late final _signIn = ref.mutation((ref, Nil _) async {
    await UserAuthProviders.signIn(
      ref,
      email: _emailFb.state.value,
      password: _passwordFb.state.value,
    );
  });

  late final _sendPasswordResetEmail = ref.mutation((ref, Nil _) async {
    await UserAuthProviders.sendPasswordResetEmail(ref, _emailFb.state.value);
  }, onSuccess: (_, __) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Sent password reset email to ${_emailFb.state.value}!'),
    ));
  });

  @override
  void initState() {
    super.initState();
    _form.addFieldBlocs([_emailFb, _passwordFb]);
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = ref.watchIdle(mutations: [_signIn, _sendPasswordResetEmail]);

    final signIn = context.handleSubmit(_form, _signIn.run);
    final sendPasswordResetEmail = context.handleSubmit(_emailFb, _sendPasswordResetEmail.run);

    List<Widget> buildFields() {
      return [
        FieldText(
          fieldBloc: _emailFb,
          converter: FieldConvert.text,
          type: const TextFieldType.email(),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        FieldText(
          fieldBloc: _passwordFb,
          converter: FieldConvert.text,
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
            )
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
