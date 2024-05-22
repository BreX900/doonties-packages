import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailFb = FieldBloc(
    initialValue: UserAuthProviders.debug.email,
    validator: Validation.email,
  );
  final _passwordFb = FieldBloc(
    initialValue: UserAuthProviders.debug.password,
    validator: Validation.password,
  );
  final _passwordConfirmationFb = FieldBloc(
    initialValue: UserAuthProviders.debug.password,
    validator: Validation.password,
  );

  late final _form = ListFieldBloc<void>(
    fieldBlocs: [_emailFb, _passwordFb, _passwordConfirmationFb],
  );

  @override
  void dispose() {
    unawaited(_form.close());
    super.dispose();
  }

  late final _signUp = ref.mutation((ref, Nil _) async {
    await UserAuthProviders.signUp(
      ref,
      email: _emailFb.state.value,
      password: _passwordFb.state.value,
      passwordConfirmation: _passwordConfirmationFb.state.value,
    );
  });

  @override
  Widget build(BuildContext context) {
    final isIdle = ref.watchIdle(mutations: [_signUp]);
    final signUp = context.handleMutation(_form, _signUp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up!'),
      ),
      bottomNavigationBar: BottomButtonBar(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isIdle ? () => signUp(nil) : null,
              child: const Text('Sign Up!'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FieldText(
              fieldBloc: _emailFb,
              converter: FieldConvert.text,
              type: const TextFieldType.email(),
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            FieldText(
              fieldBloc: _passwordFb,
              converter: FieldConvert.text,
              type: const TextFieldType.password(),
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),
            FieldText(
              fieldBloc: _passwordConfirmationFb,
              converter: FieldConvert.text,
              type: const TextFieldType.password(),
              decoration: const InputDecoration(
                labelText: 'Password Confirmation',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
