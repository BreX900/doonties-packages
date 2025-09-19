import 'package:flutter/material.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class SignUpScreenBase extends SourceConsumerStatefulWidget {
  AsyncHandler get asyncHandler;

  const SignUpScreenBase({super.key});

  @override
  SourceConsumerState<SignUpScreenBase> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends SourceConsumerState<SignUpScreenBase> {
  final _emailFb = FormControlTyped<String>(
    initialValue: const String.fromEnvironment('_DEBUG_EMAIL'),
    validators: [ValidatorsTyped.required(), ValidatorsTyped.email()],
  );
  final _passwordFb = FormControlTyped<String>(
    initialValue: const String.fromEnvironment('_DEBUG_PASSWORD'),
    validators: [ValidatorsTyped.required(), ValidatorsTyped.password()],
  );
  final _passwordConfigController = ValueNotifier(TextConfig.password);
  final _passwordConfirmationFb = FormControlTyped<String>(
    initialValue: const String.fromEnvironment('_DEBUG_PASSWORD'),
    validators: [ValidatorsTyped.required(), ValidatorsTyped.password()],
  );
  final _passwordConfirmationConfigController = ValueNotifier(TextConfig.password);

  late final _form = FormArray([_emailFb, _passwordFb, _passwordConfirmationFb]);

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  late final _signUp = scope.mutation((ref, None _) async {
    await UserAuthProviders.signUp(
      email: _emailFb.value,
      password: _passwordFb.value,
      passwordConfirmation: _passwordConfirmationFb.value,
    );
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
  });

  @override
  Widget build(BuildContext context) {
    final isIdle = !scope.watchIsMutating([_signUp]);
    final signUp = _form.handleSubmit(_signUp.run, keepDisabled: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up!'),
      ),
      bottomNavigationBar: BottomButtonBar(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isIdle ? () => signUp(none) : null,
              child: const Text('Sign Up!'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ReactiveTypedTextField(
              formControl: _emailFb,
              variant: const TextFieldVariant.email(),
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            ReactiveTypedTextField(
              formControl: _passwordFb,
              variant: const TextFieldVariant.password(),
              config: _passwordConfigController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: ReactiveVisibilityButton(controller: _passwordConfigController),
              ),
            ),
            ReactiveTypedTextField(
              formControl: _passwordConfirmationFb,
              variant: const TextFieldVariant.password(),
              config: _passwordConfirmationConfigController,
              decoration: InputDecoration(
                labelText: 'Password Confirmation',
                suffixIcon:
                    ReactiveVisibilityButton(controller: _passwordConfirmationConfigController),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
