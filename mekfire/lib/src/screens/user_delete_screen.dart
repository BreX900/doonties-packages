import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:mekfire/src/widgets/_confirmable_dialog.dart';

abstract class UserDeleteScreenBase extends ConsumerStatefulWidget {
  const UserDeleteScreenBase({super.key});

  Future<void> onDelete(MutationRef<void> ref, String email, String password);

  @override
  ConsumerState<UserDeleteScreenBase> createState() => _UserDeleteScreenState();
}

class _UserDeleteScreenState extends ConsumerState<UserDeleteScreenBase> {
  final _emailFieldBloc = FieldBloc(
    initialValue: '',
    validator: const TextValidation(minLength: 1),
  );
  final _passwordFieldBloc = FieldBloc(
    initialValue: '',
    validator: const TextValidation(minLength: 1),
  );

  final _form = ListFieldBloc<void>();

  late final _deleteUser = ref.mutation((ref, Nil _) async {
    await widget.onDelete(ref, _emailFieldBloc.state.value, _passwordFieldBloc.state.value);
  }, onWillMutate: (_) async {
    return await showTypedDialog(
      context: context,
      builder: (context) => const ConfirmableDialog.delete(
        title: Text('Delete the user?'),
        content: Text('This action is not reversible.\n'
            'All user data will be deleted and cannot be restored.'),
      ),
    );
  });

  @override
  void initState() {
    super.initState();
    _form.addFieldBlocs([_emailFieldBloc, _passwordFieldBloc]);
    // if (Env.debugPassword.isNotEmpty) _passwordFb.changeValue(Env.debugPassword);
  }

  Widget _buildBody() {
    final isIdle = ref.watchIdle(mutations: [_deleteUser]);

    final deleteUser = context.handleMutation(_form, _deleteUser);

    List<Widget> buildFields() {
      return [
        FieldText(
          fieldBloc: _emailFieldBloc,
          converter: FieldConvert.text,
          type: const TextFieldType.email(),
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        FieldText(
          fieldBloc: _passwordFieldBloc,
          converter: FieldConvert.text,
          type: const TextFieldType.password(),
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
                onPressed: isIdle ? () => deleteUser(nil) : null,
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
    final isIdle = ref.watchIdle(mutations: [_deleteUser]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete user?'),
        flexibleSpace: Consumer(builder: (context, ref, _) {
          final progress = ref.watch(_deleteUser.select((state) => state.progressOrNull));
          return LinearProgressIndicatorBar(isHidden: isIdle, value: progress);
        }),
      ),
      body: _buildBody(),
    );
  }
}
