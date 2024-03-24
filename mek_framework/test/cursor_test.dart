import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mek/src/material/cursor_data.dart';

Cursor _cursor(int page, [String? prevPageLastOffset]) {
  return Cursor(
    size: CursorBloc.defaultSize,
    page: page,
    prevPageLastOffset: prevPageLastOffset,
  );
}

void main() {
  group('CursorState', () {
    test('loading first page', () {
      final state = CursorState(size: CursorBloc.defaultSize);

      expect(state.page, 0);
      expect(state.isPageFirst, true);
      expect(state.isPageLast, false);
      expect(state.hasFirstPage, false);
      expect(state.hasLastPage, false);
      expect(state.cursors, [_cursor(0)]);
    });

    test('loaded first page', () {
      final state = CursorState(
        size: CursorBloc.defaultSize,
        lastPagesOffsets: const IMapConst({0: null}),
      );

      expect(state.page, 0);
      expect(state.isPageFirst, true);
      expect(state.isPageLast, false);
      expect(state.hasFirstPage, true);
      expect(state.hasLastPage, false);
      expect(state.cursors, [_cursor(0)]);
    });

    test('loading last page', () {
      final state = CursorState(
        size: CursorBloc.defaultSize,
        lastPagesOffsets: const IMapConst({0: 'zero', 1: null}),
        page: 1,
      );

      expect(state.page, 1);
      expect(state.isPageFirst, false);
      expect(state.isPageLast, false);
      expect(state.hasFirstPage, true);
      expect(state.hasLastPage, false);
      expect(state.cursors, [_cursor(0), _cursor(1, 'zero')]);
    });

    test('loaded last page', () {
      final state = CursorState(
        size: CursorBloc.defaultSize,
        lastPagesOffsets: const IMapConst({0: 'zero', 1: null}),
        page: 1,
        lastPage: 1,
      );

      expect(state.page, 1);
      expect(state.isPageFirst, false);
      expect(state.isPageLast, true);
      expect(state.hasFirstPage, true);
      expect(state.hasLastPage, true);
      expect(state.cursors, [_cursor(0), _cursor(1, 'zero')]);
    });
  });
}
