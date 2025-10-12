import 'package:flutter/material.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/widgets/_confirmable_dialog.dart';
import 'package:reactive_forms/reactive_forms.dart';

abstract class UserDeleteScreenBase extends SourceConsumerStatefulWidget {
  const UserDeleteScreenBase({super.key});

  AsyncHandler get asyncHandler;

  Future<void> onDelete(MutationRef ref, String email, String password);

  @override
  SourceConsumerState<UserDeleteScreenBase> createState() => _UserDeleteScreenState();
}

class _UserDeleteScreenState extends SourceConsumerState<UserDeleteScreenBase> {
  final _emailFieldBloc = FormControlTyped<String>(
    initialValue: '',
    validators: [ValidatorsTyped.required(), ValidatorsTyped.email()],
  );
  final _passwordFieldBloc = FormControlTyped<String>(
    initialValue: '',
    validators: [ValidatorsTyped.required()],
  );

  late final _form = FormArray([_emailFieldBloc, _passwordFieldBloc]);

  late final _deleteUser = scope.mutation((ref, None _) async {
    await widget.onDelete(ref, _emailFieldBloc.value, _passwordFieldBloc.value);
  }, onWillMutate: (_) async {
    return await showTypedDialog(
      context: context,
      builder: (context) => const ConfirmableDialog.delete(
        title: Text('Delete the user?'),
        content: Text('This action is not reversible.\n'
            'All user data will be deleted and cannot be restored.'),
      ),
    );
  }, onError: (_, error) {
    widget.asyncHandler.showError(context, error);
  });

  @override
  void initState() {
    super.initState();
    // if (Env.debugPassword.isNotEmpty) _passwordFb.changeValue(Env.debugPassword);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Widget _buildBody({required bool isIdle}) {
    final deleteUser = _form.handleSubmitWith(_deleteUser.run);

    List<Widget> buildFields() {
      return [
        ReactiveTypedTextField(
          formControl: _emailFieldBloc,
          variant: const TextFieldVariant.email(),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        ReactiveTypedTextField(
          formControl: _passwordFieldBloc,
          variant: const TextFieldVariant.password(),
          decoration: const InputDecoration(labelText: 'Password'),
        ),
      ];
    }

    return SafeArea(
      minimum: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...buildFields(),
          const SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: isIdle ? () => deleteUser(none) : null,
                icon: const Icon(Icons.delete_forever_outlined),
                label: const Text('Delete'),
              ),
              const SizedBox(height: 16.0),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMutating = scope.watchIsMutating([_deleteUser]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete user?'),
        flexibleSpace: SourceConsumer(builder: (context, scope, _) {
          final progress = scope.watch(_deleteUser.source.select((state) => state.progressOrNull));
          return FlexibleLinearProgressBar(visible: isMutating, value: progress);
        }),
      ),
      body: _buildBody(isIdle: !isMutating),
    );
  }
}
