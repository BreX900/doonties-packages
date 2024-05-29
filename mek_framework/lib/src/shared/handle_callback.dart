import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';
import 'package:meta/meta.dart';

extension FormBuildContextExtensions on BuildContext {
  @Deprecated('In favour of handleMutation')
  void Function(T args) handleSubmit<T>(
    FieldBlocRule<dynamic> form,
    FutureOr<void> Function(T args) submitter, {
    @Deprecated('In favour of isFormDisabledAfterSubmit') bool canEnableFormAfterSubmit = true,
    bool? isFormDisabledAfterSubmit,
    @internal bool shouldThrow = true,
  }) {
    isFormDisabledAfterSubmit ??= !canEnableFormAfterSubmit;
    return (arg) async {
      if (!form.state.status.isValid) {
        form.touch();
        await SkeletonForm.requestFocusOnError(this);
        return;
      }
      final submitting = submitter(arg);
      if (submitting is! Future) return;
      form.disable();
      try {
        await submitting;
        if (!form.isClosed && !isFormDisabledAfterSubmit!) form.enable();
      } catch (_) {
        if (!form.isClosed) form.enable();
        if (shouldThrow) rethrow;
      }
    };
  }

  void Function(T args) handleMutation<T>(
    FieldBlocRule<dynamic> form,
    MutationBloc<T, void> mutation, {
    bool? isFormDisabledAfterSubmit,
    @Deprecated('In favour of isFormDisabledAfterSubmit') bool canEnableFormAfterSubmit = true,
  }) {
    // ignore: deprecated_member_use_from_same_package
    return handleSubmit(
      form,
      mutation.run,
      isFormDisabledAfterSubmit: isFormDisabledAfterSubmit,
      // ignore: deprecated_member_use_from_same_package
      canEnableFormAfterSubmit: canEnableFormAfterSubmit,
      shouldThrow: false,
    );
  }
}

extension HandleWidgetRef on WidgetRef {
  static bool shouldFormValid = true;

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
      shouldValid: shouldFormValid,
    )));
  }

  bool watchCanApplyFilters(FieldBlocRule<dynamic> form) {
    return watch(form.select(_FormSelector(
      shouldDirty: true,
      shouldHasNotUpdatedValue: true,
      shouldValid: shouldFormValid,
    )));
  }

  bool watchIsValid(FieldBlocRule<dynamic> form) {
    return watch(form.select(const _FormSelector(shouldValid: true)));
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
      shouldValid: true,
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
  final bool shouldValid;

  const _FormSelector({
    this.shouldDirty = false,
    this.shouldHasNotUpdatedValue = false,
    this.shouldValid = false,
  });

  bool call(FieldBlocStateBase<dynamic> state) {
    if (shouldDirty && !state.isDirty) return false;
    if (shouldHasNotUpdatedValue && state.hasUpdatedValue) return false;
    if (shouldValid && !state.status.isValid) return false;
    return true;
  }

  @override
  List<Object?> get props => [shouldDirty, shouldHasNotUpdatedValue, shouldValid];
}

class _Val {
  _Val(this.entries);

  final Map<Object, bool> entries;

  bool get isBusy => entries.values.any((isBusy) => isBusy);

  // ignore: avoid_positional_boolean_parameters
  _Val update(Object key, bool isBusy) => _Val({...entries, key: isBusy});
}
