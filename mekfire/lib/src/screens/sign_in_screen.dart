import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class SignInScreenBase extends ConsumerStatefulWidget {
  const SignInScreenBase({super.key});

  AsyncHandler get asyncHandler;

  void onSignUpPressed(BuildContext context);

  Widget? buildFooter(BuildContext context) => null;

  @override
  ConsumerState<SignInScreenBase> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreenBase> {
  late final _mutation = MutationController<void>(ref);

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

  @override
  void dispose() {
    _form.dispose();
    _mutation.dispose();
    super.dispose();
  }

  void _signIn() => _mutation(
    (ref) async {
      _form.markAsDisabled();
      await UserAuthProviders.signIn(email: _emailFb.value, password: _passwordFb.value);
    },
    onError: (error, _) {
      _form.markAsEnabled();
      widget.asyncHandler.showError(context, error);
    },
  );

  void _sendPasswordResetEmail() => _mutation(
    (ref) async => await UserAuthProviders.sendPasswordResetEmail(_emailFb.value),
    onError: (error, _) => widget.asyncHandler.showError(context, error),
    onSuccess: (_) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Sent password reset email to ${_emailFb.value}!'))),
  );

  @override
  Widget build(BuildContext context) {
    final isIdle = !ref.watch(_mutation.provider.isPending);

    final signIn = _form.handleSubmit(_signIn);
    final sendPasswordResetEmail = _emailFb.handleSubmit(_sendPasswordResetEmail);

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
          onSubmitted: isIdle ? (_) => signIn() : null,
          decoration: InputDecoration(
            labelText: 'Password',
            suffixIcon: ReactiveVisibilityButton(controller: _passwordConfigController),
          ),
        ),
        TextButton.icon(
          onPressed: isIdle ? sendPasswordResetEmail : null,
          icon: const Icon(Icons.lock_reset_outlined),
          label: const Text('Send reset password email'),
        ),
      ];
    }

    final footer = widget.buildFooter(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Sign In')),
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
                  onPressed: isIdle ? signIn : null,
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
