import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';

abstract class PaginationModel<T extends PaginationModel<T>> {
  final int? pageSize;
  final int? pageIndex;

  const PaginationModel({required this.pageSize, required this.pageIndex});

  T copyWith({int? pageSize, int? pageIndex});
}

class PaginationValue<T> extends Equatable {
  final int currentIndex;
  final bool canLoadMore;
  final IMap<int, IList<T>> pages;
  IList<T> get models => pages.values.flattenedToList.lockUnsafe;

  const PaginationValue({
    required this.currentIndex,
    required this.canLoadMore,
    required this.pages,
  });

  @override
  String toString() =>
      'PaginationValue<$T>(\n'
      '  currentIndex: $currentIndex,\n'
      '  canLoadMore: $canLoadMore,\n'
      '  pages: {${pages.mapTo((index, models) => '    $index: ${models.unlockView}\n')}},\n'
      ')';

  @override
  List<Object?> get props => [currentIndex, canLoadMore, models];
}

typedef PaginationFetcher<T, Arg> = Future<IList<T>> Function(PaginationRef ref, Arg arg);

class PaginationNotifier<T, Arg extends PaginationModel<Arg>>
    extends AsyncNotifier<PaginationValue<T>> {
  final Arg _arg;
  final PaginationFetcher<T, Arg> _fetcher;
  final FutureOr<void> Function(Ref ref)? _onCreate;

  late int _size;
  var _token = Object();

  PaginationNotifier(this._arg, this._fetcher, this._onCreate);

  Future<void> loadMore() {
    if (state.isLoading) throw StateError('Is loading. Please wait load!');
    final value = state.value;
    if (value == null) throw StateError('Value is null. Please refresh the provider!');
    final index = value.currentIndex + 1;

    // ignore: invalid_use_of_internal_member
    state = AsyncValue<PaginationValue<T>>.loading().copyWithPrevious(state);
    return _loadMore(_token, value, index);
  }

  Future<void> _loadMore(Object token, PaginationValue<T> value, int index) async {
    final state = await AsyncValue.guard(() async {
      final models = await _fetcher(_ref(), _arg.copyWith(pageSize: _size, pageIndex: index));

      return PaginationValue(
        currentIndex: models.isNotEmpty ? index : index - 1,
        canLoadMore: models.length >= _size,
        pages: models.isNotEmpty ? value.pages.add(index, models) : value.pages,
      );
    });
    // If the token has changed it means that the notifier has been rebuilt
    if (token != _token) return;
    this.state = state;
  }

  @override
  Future<PaginationValue<T>> build() {
    assert(
      _arg.pageSize != null && _arg.pageSize! > 0,
      'Missing $Arg.pageSize field. Pass it to correct handling a fetches.',
    );
    assert(
      _arg.pageIndex == null,
      'Exists $Arg.pageIndex field. Do not pass it to avoid duplicated states.',
    );

    ref.onDispose(() => _token = Object());
    _size = _arg.pageSize ?? 50;

    return _build(_arg);
  }

  Future<PaginationValue<T>> _build(Arg arg) async {
    const index = 0;

    // TODO: Should it be done immediately?
    await _onCreate?.call(ref);

    // TODO: Should it be done immediately?
    final models = await _fetcher(_ref(), arg.copyWith(pageSize: _size, pageIndex: index));

    return PaginationValue(
      currentIndex: index,
      canLoadMore: models.length >= _size,
      pages: models.isNotEmpty ? {index: models}.lockUnsafe : IMap<int, IList<T>>.empty(),
    );
  }

  PaginationRef _ref() => PaginationRef._(ref);
}

class PaginationRef {
  final Ref _ref;

  PaginationRef._(this._ref);

  ProviderContainer get container => _ref.container;

  @useResult
  T refresh<T>(Refreshable<T> provider) => _ref.refresh(provider);

  void invalidate(ProviderOrFamily provider) => _ref.invalidate(provider);

  void notifyListeners() => _ref.notifyListeners();

  void invalidateSelf() => _ref.invalidateSelf();

  T read<T>(ProviderListenable<T> provider) => _ref.read(provider);

  bool exists(ProviderBase<Object?> provider) => _ref.exists(provider);

  T watch<T>(ProviderListenable<T> provider) => _ref.watch(provider);
}

// // ignore: subtype_of_sealed_class
// class PaginationNotifierProvider<T, Arg extends PaginationModel<Arg>>
//     extends AsyncNotifierProvider<PaginationNotifier<T, Arg>, PaginationValue<T>> {
//   PaginationNotifierProvider(
//     PaginationFetcher<T, Arg> fetcher, {
//     FutureOr<void> Function(Ref ref)? onCreate,
//   }) : super(() => PaginationNotifier<T, Arg>(fetcher, onCreate));
// }

extension AsyncPaginationValueExtensions on AsyncValue<PaginationValue> {
  bool get canRefresh => !isLoading;
  bool get canLoadMore => !isLoading && hasValue && requireValue.canLoadMore;
}
