import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

abstract class MutationRef {
  final ProviderContainer _ref;

  MutationRef(this._ref);

  bool get mounted;

  bool exists(ProviderBase<Object?> provider) {
    MutationRef.ensureIsMounted(this);
    return _ref.exists(provider);
  }

  void invalidate(ProviderOrFamily provider) {
    MutationRef.ensureIsMounted(this);
    _ref.invalidate(provider);
  }

  T read<T>(ProviderListenable<T> provider) {
    MutationRef.ensureIsMounted(this);
    return _ref.read(provider);
  }

  T refresh<T>(Refreshable<T> provider) {
    MutationRef.ensureIsMounted(this);
    return _ref.refresh(provider);
  }

  void updateProgress(double value);

  static void ensureIsMounted(MutationRef ref) {
    assert(ref.mounted);
  }
}
