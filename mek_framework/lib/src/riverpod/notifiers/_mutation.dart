import 'package:mek/src/riverpod/notifiers/mutation_ref.dart';

class MutationRefImpl<TArg> extends MutationRef {
  final MutationDelegate _delegate;
  final TArg _arg;

  MutationRefImpl(super._ref, this._delegate, this._arg);

  @override
  void updateProgress(double value) {
    debugEnsureIsMounted();
    _delegate.updateProgress(_arg, value);
  }

  @override
  void dispose() => super.dispose();
}

abstract class MutationDelegate<TArg> {
  void updateProgress(TArg arg, double value);
}
