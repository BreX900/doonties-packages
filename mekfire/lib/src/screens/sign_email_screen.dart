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
  late final _sendEmailVerification = ref.mutation((ref, arg) async {
    await UserAuthProviders.sendEmailVerification();
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
  }, onSuccess: (_, __) {
    ScaffoldMessenger.of(context).showMaterialBanner(const MaterialBanner(
      content: Text('Verification email sent!'),
      actions: [HideBannerButton()],
    ));
  });

  late final _reload = ref.mutation((ref, arg) async {
    await UserAuthProviders.checkEmailVerification();
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
  });

  late final _signOut = ref.mutation((ref, arg) async {
    await UserAuthProviders.signOut();
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
  });

  @override
  Widget build(BuildContext context) {
    final isIdle = !ref.watchIsMutating([_sendEmailVerification, _reload, _signOut]);

    return Scaffold(
      appBar: AppBar(
        leading: const SignOutIconButton(),
        title: const Text('Verify email!'),
        actions: [
          IconButton(
            onPressed: isIdle ? () => _signOut(null) : null,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: isIdle ? () => _reload(null) : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: InfoView(
        onTap: isIdle ? () => _reload(null) : null,
        icon: const Icon(Icons.mark_email_unread_outlined),
        title: Text('Please verify your email:\n'
            '${UserAuthProviders.current!.email}'),
        description: const Text('Tap to verify that you have reset the email'),
      ),
      bottomNavigationBar: BottomButtonBar(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isIdle ? () => _sendEmailVerification(null) : null,
              child: const Text('Send email verification'),
            ),
          ),
        ],
      ),
    );
  }
}
