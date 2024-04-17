import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/data/mutation_state.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek/src/riverpod/riverpod_adapters.dart';
import 'package:mek/src/shared/skeleton_form.dart';

extension FormBuildContextExtensions on BuildContext {
  VoidCallback handleSubmit(
    FieldBlocRule<dynamic> form,
    FutureOr<void> Function() submitter, {
    bool canEnableFormAfterSubmit = true,
  }) {
    return () async {
      if (!form.state.status.isValid) {
        form.touch();
        await SkeletonForm.requestFocusOnError(this);
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
}

extension HandleWidgetRef on WidgetRef {
  @Deprecated('')
  VoidCallback? handleSubmit(
    FieldBlocRule<dynamic> form,
    FutureOr<void> Function() submitter, {
    bool shouldDirty = true,
    bool shouldHasNotUpdatedValue = true,
    bool canEnableFormAfterSubmit = true,
  }) {
    final canSubmit = watch(form.select(_FormSelector(
      shouldDirty: shouldDirty,
      shouldHasNotUpdatedValue: shouldHasNotUpdatedValue,
    )));
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

  bool watchCanUpsert(FieldBlocRule<dynamic> form, {required bool isCreate}) {
    return watch(form.select(_FormSelector(
      shouldHasNotUpdatedValue: !isCreate,
    )));
  }

  bool watchCanApplyFilters(FieldBlocRule<dynamic> form) {
    return watch(form.select(const _FormSelector(
      shouldDirty: true,
      shouldHasNotUpdatedValue: true,
    )));
  }

  bool watchIsValid(FieldBlocRule<dynamic> form) {
    return watch(form.select(const _FormSelector()));
  }

  @Deprecated('')
  bool watchCanSubmit(
    FieldBlocRule<dynamic> form, {
    bool shouldDirty = true,
    bool shouldHasNotUpdatedValue = true,
  }) {
    return watch(form.select(_FormSelector(
      shouldDirty: shouldDirty,
      shouldHasNotUpdatedValue: shouldHasNotUpdatedValue,
    )));
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

class _FormSelector with EquatableMixin {
  final bool shouldDirty;
  final bool shouldHasNotUpdatedValue;

  const _FormSelector({
    this.shouldDirty = false,
    this.shouldHasNotUpdatedValue = false,
  });

  bool call(FieldBlocStateBase<dynamic> state) {
    if (shouldDirty && !state.isDirty) return false;
    if (shouldHasNotUpdatedValue && state.hasUpdatedValue) return false;
    return state.status.isValid;
  }

  @override
  List<Object?> get props => [shouldDirty, shouldHasNotUpdatedValue];
}

class _Val {
  _Val(this.entries);

  final Map<Object, bool> entries;

  bool get isBusy => entries.values.any((isBusy) => isBusy);

  // ignore: avoid_positional_boolean_parameters
  _Val update(Object key, bool isBusy) => _Val({...entries, key: isBusy});
}
