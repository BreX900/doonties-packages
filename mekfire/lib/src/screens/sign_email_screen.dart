import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/providers/auth_providers.dart';
import 'package:mekfire/src/widgets/sign_out_icon_button.dart';

abstract class EmailVerificationScreenBase extends ConsumerStatefulWidget {
  AsyncHandler get asyncHandler;

  const EmailVerificationScreenBase({super.key});

  @override
  ConsumerState<EmailVerificationScreenBase> createState() => _SignEmailScreenState();
}

class _SignEmailScreenState extends ConsumerState<EmailVerificationScreenBase> {
  late final _mutation = MutationController<void>(ref);

  @override
  void dispose() {
    _mutation.dispose();
    super.dispose();
  }

  void _sendEmailVerification() => _mutation(
    (ref) async => await UserAuthProviders.sendEmailVerification(),
    onError: (error, _) => widget.asyncHandler.showError(context, error),
    onSuccess: (_) => ScaffoldMessenger.of(context).showMaterialBanner(
      const MaterialBanner(
        content: Text('Verification email sent!'),
        actions: [HideBannerButton()],
      ),
    ),
  );

  void _reload() => _mutation(
    (ref) async => await UserAuthProviders.checkEmailVerification(),
    onError: (error, _) => widget.asyncHandler.showError(context, error),
  );

  void _signOut() => _mutation(
    (ref) async => await UserAuthProviders.signOut(),
    onError: (error, _) => widget.asyncHandler.showError(context, error),
  );

  @override
  Widget build(BuildContext context) {
    final isIdle = !ref.watch(_mutation.provider.isPending);

    return Scaffold(
      appBar: AppBar(
        leading: const SignOutIconButton(),
        title: const Text('Verify email!'),
        actions: [
          IconButton(onPressed: isIdle ? _signOut : null, icon: const Icon(Icons.logout)),
          IconButton(onPressed: isIdle ? _reload : null, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: InfoView(
        onTap: isIdle ? _reload : null,
        icon: const Icon(Icons.mark_email_unread_outlined),
        title: Text(
          'Please verify your email:\n'
          '${UserAuthProviders.current!.email}',
        ),
        description: const Text('Tap to verify that you have reset the email'),
      ),
      bottomNavigationBar: BottomButtonBar(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isIdle ? _sendEmailVerification : null,
              child: const Text('Send email verification'),
            ),
          ),
        ],
      ),
    );
  }
}
