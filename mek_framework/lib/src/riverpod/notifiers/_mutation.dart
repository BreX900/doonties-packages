import 'package:mek/mek.dart';

class MutationRefImpl<TArg> extends MutationRef {
  Mutation? _delegate;
  final TArg _arg;

  MutationRefImpl(super._ref, this._delegate, this._arg);

  @override
  void updateProgress(double value) {
    assert(_delegate != null);
    _delegate?.updateProgress(_arg, value);
  }

  void dispose() {
    _delegate = null;
  }
}

abstract class Mutation<TArg> {
  void updateProgress(TArg arg, double value);
}
