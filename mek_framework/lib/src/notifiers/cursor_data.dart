import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:mek/src/source/source.dart';
import 'package:mekart/mekart.dart';

class Cursor with EquatableAndDescribable {
  final int size;
  final int page;
  final String? prevPageLastOffset;

  int get offset => page * size;

  const Cursor({
    required this.size,
    required this.page,
    required this.prevPageLastOffset,
  });

  @override
  Map<String, Object?> get props =>
      {'size': size, 'page': page, 'prevPageLastOffset': prevPageLastOffset};
}

class CursorState with EquatableAndDescribable {
  final String? debugLabel;
  final int size;
  final int? lastPage;
  final IMap<int, String?> lastPagesOffsets;
  final int page;

  late final bool hasFirstPage = lastPagesOffsets.containsKey(0);
  late final bool hasLastPage = lastPagesOffsets.containsKey(lastPage);

  late final bool isPageFirst = page == 0;
  late final bool isPageLast = page == lastPage;

  late final Cursor pageCursor = cursorAt(page);

  late final Iterable<Cursor> cursors =
      ISet(lastPagesOffsets.keys).add(page).map(cursorAt).toIList();

  CursorState({
    this.debugLabel,
    required this.size,
    this.lastPage,
    IMap<int, String?>? lastPagesOffsets,
    this.page = 0,
  })  : lastPagesOffsets =
            (lastPagesOffsets ?? const IMapConst({})).withConfig(const ConfigMap(sort: true)),
        assert(size > 1),
        assert(page >= 0),
        assert(lastPagesOffsets?.keys.every((e) => e >= 0) ?? true);

  Cursor cursorAt(int index) =>
      Cursor(size: size, page: index, prevPageLastOffset: lastPagesOffsets[index - 1]);

  CursorState copyWith({
    int? size,
    int? lastPage,
    IMap<int, String?>? lastPagesOffsets,
    int? page,
  }) =>
      CursorState(
        debugLabel: debugLabel,
        size: size ?? this.size,
        lastPage: lastPage ?? this.lastPage,
        lastPagesOffsets: lastPagesOffsets ?? this.lastPagesOffsets,
        page: page ?? this.page,
      );

  @override
  Map<String, Object?> get props => {
        'size': size,
        'lastPage': lastPage,
        'lastPagesOffsets': lastPagesOffsets,
        'page': page,
      };

  @override
  String toString() {
    final offsetsString = lastPagesOffsets.entries.map((e) {
      final info = '${e.key}${e.value != null ? ':${e.value}' : ''}';
      return e.key == page ? '{$info}' : info;
    }).join(',');
    return 'CursorState#${debugLabel ?? '?'}<$size,${lastPage ?? '?'}>($offsetsString)';
  }
}

class CursorBloc extends SourceNotifier<CursorState> {
  static int defaultSize = 20;

  CursorBloc({String? debugLabel, int? size})
      : super(CursorState(debugLabel: debugLabel, size: size ?? CursorBloc.defaultSize));

  void registerPage(int length, {int? page, Iterable<String>? offsets}) {
    if (state.lastPage != null) return;

    // Mark not exist more offsets if page not has correct size.
    // If page is empty move to previous page.

    page ??= state.page;

    final endAtPage = length >= state.size ? null : max(0, page + (length == 0 ? -1 : 0));
    final nextPage = max(0, state.page + (length == 0 ? -1 : 0));
    final updatedOffsets =
        state.lastPagesOffsets.add(page, offsets?.elementAtOrNull(state.size - 1));

    state = state.copyWith(
      lastPage: endAtPage,
      lastPagesOffsets: updatedOffsets,
      page: nextPage,
    );
  }

  void registerOffsets(Iterable<String> offsets, {int? page}) =>
      registerPage(offsets.length, page: page, offsets: offsets);

  void moveToPrevious() => moveTo(state.page - 1);

  void moveToNext() => moveTo(state.page + 1);

  void moveTo(int pageIndex) {
    final hasCurrentPage = state.lastPagesOffsets.containsKey(state.page);
    if (!hasCurrentPage) return;

    final hasPage = state.lastPagesOffsets.containsKey(pageIndex);
    final isNextPage = pageIndex <= state.lastPagesOffsets.keys.last + 1;
    if (!(hasPage || isNextPage)) return;

    if (state.lastPage != null) {
      final isInAvailablePages = pageIndex <= state.lastPage!;
      if (!isInAvailablePages) return;
    }

    state = state.copyWith(page: pageIndex);
  }

  void clean() => state = CursorState(size: state.size);
}
