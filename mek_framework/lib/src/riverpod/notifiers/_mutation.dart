import 'package:mek/src/riverpod/notifiers/mutation_ref.dart';

class MutationRefImpl<TArg> extends MutationRef {
  final MutationDelegate _delegate;
  final TArg _arg;

  MutationRefImpl(super._ref, this._delegate, this._arg);

  @override
  bool mounted = true;

  @override
  void updateProgress(double value) {
    MutationRef.ensureIsMounted(this);
    _delegate.updateProgress(_arg, value);
  }

  void dispose() {
    mounted = false;
  }
}

abstract class MutationDelegate<TArg> {
  void updateProgress(TArg arg, double value);
}
