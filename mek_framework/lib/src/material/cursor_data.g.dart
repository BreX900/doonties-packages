// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cursor_data.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

mixin _$Cursor {
  Cursor get _self => this as Cursor;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cursor &&
          runtimeType == other.runtimeType &&
          _self.size == other.size &&
          _self.page == other.page &&
          _self.prevPageLastOffset == other.prevPageLastOffset;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.size.hashCode);
    hashCode = $hashCombine(hashCode, _self.page.hashCode);
    hashCode = $hashCombine(hashCode, _self.prevPageLastOffset.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('Cursor')
        ..add('size', _self.size)
        ..add('page', _self.page)
        ..add('prevPageLastOffset', _self.prevPageLastOffset))
      .toString();
}

mixin _$CursorState {
  CursorState get _self => this as CursorState;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursorState &&
          runtimeType == other.runtimeType &&
          _self.debugLabel == other.debugLabel &&
          _self.size == other.size &&
          _self.lastPage == other.lastPage &&
          _self.lastPagesOffsets == other.lastPagesOffsets &&
          _self.page == other.page;
  @override
  int get hashCode {
    var hashCode = 0;
    hashCode = $hashCombine(hashCode, _self.debugLabel.hashCode);
    hashCode = $hashCombine(hashCode, _self.size.hashCode);
    hashCode = $hashCombine(hashCode, _self.lastPage.hashCode);
    hashCode = $hashCombine(hashCode, _self.lastPagesOffsets.hashCode);
    hashCode = $hashCombine(hashCode, _self.page.hashCode);
    return $hashFinish(hashCode);
  }

  @override
  String toString() => (ClassToString('CursorState')
        ..add('debugLabel', _self.debugLabel)
        ..add('size', _self.size)
        ..add('lastPage', _self.lastPage)
        ..add('lastPagesOffsets', _self.lastPagesOffsets)
        ..add('page', _self.page))
      .toString();
  CursorState change(void Function(_CursorStateChanges c) updates) =>
      (_CursorStateChanges._(_self)..update(updates)).build();
  _CursorStateChanges toChanges() => _CursorStateChanges._(_self);
}

class _CursorStateChanges {
  _CursorStateChanges._(CursorState dc)
      : debugLabel = dc.debugLabel,
        size = dc.size,
        lastPage = dc.lastPage,
        lastPagesOffsets = dc.lastPagesOffsets,
        page = dc.page;

  String? debugLabel;

  int size;

  int? lastPage;

  IMap<int, String?> lastPagesOffsets;

  int page;

  void update(void Function(_CursorStateChanges c) updates) => updates(this);

  CursorState build() => CursorState(
        debugLabel: debugLabel,
        size: size,
        lastPage: lastPage,
        lastPagesOffsets: lastPagesOffsets,
        page: page,
      );
}
