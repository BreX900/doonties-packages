import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/src/core/_log.dart';
import 'package:mek/src/riverpod/notifiers/_mutation.dart';
import 'package:mek/src/riverpod/notifiers/mutation_state.dart';
import 'package:meta/meta.dart';

@optionalTypeArgs
class MutationRef<R> {
  final ProviderContainer _ref;
  final NotifierDelegate<MutationState<R>> _delegate;

  MutationRef(this._ref, this._delegate);

  bool exists(ProviderBase<Object?> provider) => _ref.exists(provider);

  void invalidate(ProviderOrFamily provider) => _ref.invalidate(provider);

  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  T refresh<T>(Refreshable<T> provider) => _ref.refresh(provider);

  void updateProgress(double value) {
    final state = _delegate.state;
    if (state is! LoadingMutation<R>) {
      lg.info("Bloc isn't mutating! Cant update progress state. $this");
      return;
    }
    _delegate.state = state.toLoading(arg: state.args.single, progress: value);
  }
}
