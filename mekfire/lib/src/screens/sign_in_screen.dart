import 'package:flutter/material.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class SignInScreenBase extends SourceConsumerStatefulWidget {
  const SignInScreenBase({super.key});

  AsyncHandler get asyncHandler;

  void onSignUpPressed(BuildContext context);

  Widget? buildFooter(BuildContext context) => null;

  @override
  SourceConsumerState<SignInScreenBase> createState() => _SignInScreenState();
}

class _SignInScreenState extends SourceConsumerState<SignInScreenBase> {
  final _emailFb = FormControlTyped<String>(
    initialValue: const String.fromEnvironment('_DEBUG_EMAIL'),
    validators: [ValidatorsTyped.required(), ValidatorsTyped.email()],
  );
  final _passwordFb = FormControlTyped<String>(
    initialValue: const String.fromEnvironment('_DEBUG_PASSWORD'),
    validators: [ValidatorsTyped.required()],
  );
  final _passwordConfigController = ValueNotifier(TextConfig.password);

  late final _form = FormArray([_emailFb, _passwordFb]);

  late final _signIn = scope.mutation((ref, None _) async {
    await UserAuthProviders.signIn(
      email: _emailFb.value,
      password: _passwordFb.value,
    );
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
  });

  late final _sendPasswordResetEmail = scope.mutation((ref, None _) async {
    await UserAuthProviders.sendPasswordResetEmail(_emailFb.value);
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
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
    final isIdle = !scope.watchIsMutating([_signIn, _sendPasswordResetEmail]);

    final signIn = _form.handleSubmit(_signIn.run, keepDisabled: true);
    final sendPasswordResetEmail = _emailFb.handleSubmit(_sendPasswordResetEmail.run);

    List<Widget> buildFields() {
      return [
        ReactiveTypedTextField(
          formControl: _emailFb,
          variant: const TextFieldVariant.email(),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        ReactiveTypedTextField(
          formControl: _passwordFb,
          variant: const TextFieldVariant.password(),
          config: _passwordConfigController,
          textInputAction: TextInputAction.done,
          onSubmitted: isIdle ? (_) => signIn(none) : null,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: ReactiveVisibilityButton(controller: _passwordConfigController),
          ),
        ),
        TextButton.icon(
          onPressed: isIdle ? () => sendPasswordResetEmail(none) : null,
          icon: const Icon(Icons.lock_reset_outlined),
          label: const Text('Send reset password email'),
        ),
      ];
    }

    final footer = widget.buildFooter(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                FilledButton.icon(
                  onPressed: isIdle ? () => signIn(none) : null,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In'),
                ),
                const SizedBox(height: 16.0),
                TextButton.icon(
                  onPressed: isIdle ? () => widget.onSignUpPressed(context) : null,
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Sign Up'),
                ),
                const SizedBox(height: 16.0),
              ],
            ),
            const Spacer(),
            if (footer != null) footer,
          ],
        ),
      ),
    );
  }
}
