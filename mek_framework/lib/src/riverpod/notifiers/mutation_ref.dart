import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class MutationRef {
  final ProviderContainer _ref;

  MutationRef(this._ref);

  bool exists(ProviderBase<Object?> provider) => _ref.exists(provider);

  void invalidate(ProviderOrFamily provider) => _ref.invalidate(provider);

  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  T refresh<T>(Refreshable<T> provider) => _ref.refresh(provider);

  void updateProgress(double value);
}
