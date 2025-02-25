import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageCursor {
  final int size;
  final int index;

  const PageCursor(this.size, this.index);
}

class PaginationState {
  static int get firstPageIndex => 0;

  final int pageSize;
  final IMap<int, String?> lastOffsetInPages;
  final int? lastPageIndex;
  final int currentPageIndex;

  bool get hasFirstPage => lastOffsetInPages.containsKey(firstPageIndex);
  bool get hasLastPage => lastOffsetInPages.containsKey(lastPageIndex);

  bool get isCurrentPageFirst => currentPageIndex == firstPageIndex;
  bool get isCurrentPageLast => currentPageIndex == lastPageIndex;

  PageCursor? get previousPage =>
      currentPageIndex > firstPageIndex ? PageCursor(pageSize, currentPageIndex - 1) : null;
  PageCursor get currentPage => PageCursor(pageSize, currentPageIndex);
  PageCursor? get nextPage => lastPageIndex == null || currentPageIndex <= lastPageIndex!
      ? PageCursor(pageSize, currentPageIndex + 1)
      : null;

  Iterable<PageCursor> get pages sync* {
    for (var index = 0; index <= currentPageIndex; index++) {
      yield PageCursor(index, pageSize);
    }
  }

  const PaginationState({
    required this.pageSize,
    required this.lastOffsetInPages,
    required this.lastPageIndex,
    required this.currentPageIndex,
  });

  PaginationState copyWith({
    IMap<int, String?>? lastOffsetInPages,
    required int? lastPageIndex,
    int? currentPageIndex,
  }) {
    return PaginationState(
      pageSize: pageSize,
      lastOffsetInPages: lastOffsetInPages ?? this.lastOffsetInPages,
      lastPageIndex: lastPageIndex,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
    );
  }
}

class PaginationController extends ValueNotifier<PaginationState> {
  static const PaginationState _initialState = PaginationState(
    pageSize: 10,
    lastOffsetInPages: IMap.empty(),
    lastPageIndex: null,
    currentPageIndex: 0,
  );

  PaginationController() : super(_initialState);

  void registerPage(int index, Iterable<String> offsets) {
    if (offsets.isEmpty) {
      value = value.copyWith(lastPageIndex: value.currentPageIndex);
    } else {
      final currentPageIndex = value.currentPageIndex + 1;
      value = value.copyWith(
        lastOffsetInPages: value.lastOffsetInPages.add(index, offsets.last),
        lastPageIndex: value.pageSize > offsets.length ? index : null,
        currentPageIndex: currentPageIndex,
      );
    }
  }

  void reset() {
    value = _initialState;
  }
}

extension P on ProviderListenable<PaginationState> {
  ProviderListenable<PageCursor?> get nextPage => select((state) => state.nextPage);
  ProviderListenable<Iterable<PageCursor>> get pages => select((state) => state.pages);
}

extension IListAsyncValueExtension<T> on Iterable<AsyncValue<IList<T>>> {
  AsyncValue<IList<T>> toAsyncValue() {
    final single = singleOrNull;
    if (single != null) return single;

    IList<T>? allElements;
    for (final value in this) {
      final elements = value.whenOrNull(data: (elements) => elements);
      if (elements == null) continue;

      allElements = allElements?.addAll(elements) ?? elements;
    }
    return AsyncValue.data(allElements ?? IList<T>.empty());
  }
}
