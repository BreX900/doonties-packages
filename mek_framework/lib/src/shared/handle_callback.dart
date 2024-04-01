import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/data/mutation_state.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek/src/riverpod/riverpod_adapters.dart';
import 'package:mek/src/shared/skeleton_form.dart';

extension HandleWidgetRef on WidgetRef {
  VoidCallback? handleSubmit(
    FieldBlocRule<dynamic> form,
    FutureOr<void> Function() submitter, {
    bool shouldDirty = true,
    bool shouldHasNotUpdatedValue = true,
    bool canEnableFormAfterSubmit = true,
  }) {
    final canSubmit = watch(form.select((state) {
      if (shouldDirty && !state.isDirty) return false;
      if (shouldHasNotUpdatedValue && state.hasUpdatedValue) return false;
      return true;
    }));
    if (!canSubmit) return null;

    return () async {
      if (!form.state.status.isValid) {
        form.touch();
        await SkeletonForm.requestFocusOnError(context);
        return;
      }
      final submitting = submitter();
      if (submitting is! Future) return;
      form.disable();
      try {
        await submitting;
      } finally {
        if (!form.isClosed && canEnableFormAfterSubmit) form.enable();
      }
    };
  }

  bool watchCanSubmit(
    FieldBlocRule<dynamic> form, {
    bool shouldDirty = true,
    bool shouldHasNotUpdatedValue = true,
  }) {
    return watch(form.select((state) {
      if (shouldDirty && !state.isDirty) return false;
      if (shouldHasNotUpdatedValue && state.hasUpdatedValue) return false;
      return state.status.isValid;
    }));
  }

  bool watchIdle({
    Iterable<ProviderListenable<AsyncValue<Object?>>> providers = const [],
    Iterable<StateStreamableSource<MutationState<Object?>>> mutations = const [],
  }) {
    var val = _Val({
      for (final provider in providers) provider: read(provider).isLoading,
      for (final mutationBloc in mutations) mutationBloc: mutationBloc.state.isMutating,
    });

    for (final provider in providers) {
      watch(provider.select((state) {
        val = val.update(provider, state.isLoading);
        return val.isBusy;
      }));
    }
    for (final mutationBloc in mutations) {
      watch(mutationBloc.select((state) {
        val = val.update(mutationBloc, state.isMutating);
        return val.isBusy;
      }));
    }
    return !val.isBusy;
  }
}

class _Val {
  _Val(this.entries);

  final Map<Object, bool> entries;

  bool get isBusy => entries.values.any((isBusy) => isBusy);

  // ignore: avoid_positional_boolean_parameters
  _Val update(Object key, bool isBusy) => _Val({...entries, key: isBusy});
}
