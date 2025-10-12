import 'dart:math';

import 'package:collection/collection.dart';

class Column {
  final bool isLeft;
  final int? width;

  Column.alignToLeft({this.width}) : isLeft = true;
  Column.alignToRight({this.width}) : isLeft = false;

  // int countLines(String cell) => cell.length ~/ width;
  //
  // String render(String cell) {
  //   return switch (isLeft) {
  //     true => cell.padRight(width),
  //     false => cell.padLeft(width),
  //   };
  // }

  List<String> renderLines(String cell, {required int width}) {
    final lines = <String>[];
    for (final line in cell.split('\n')) {
      for (var position = 0; position < line.length; position += width) {
        final newLine = line.substring(position, min(position + width, line.length));
        lines.add(switch (isLeft) {
          true => newLine.padRight(width),
          false => newLine.padLeft(width),
        });
      }
    }
    return lines;
  }
}

class Table {
  final Map<int, Column> columns;
  final String verticalDivisor;

  const Table({this.columns = const <int, Column>{}, this.verticalDivisor = ' '});

  String render(List<List<Object?>> rows) {
    final verticalDivisor = this.verticalDivisor;

    final columnWidths = <int, int>{};
    final columnCount = rows.first.length;
    for (var columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      final column = columns[columnIndex] ?? Column.alignToLeft();
      final columnWidth =
          column.width ?? rows.map((cells) => '${cells[columnIndex] ?? ''}'.length).max;

      columnWidths[columnIndex] = columnWidth;
    }

    return rows
        .map((cells) {
          final cellsLines = cells.mapIndexed((columnIndex, cell) {
            final column = columns[columnIndex] ?? Column.alignToLeft();
            return column.renderLines('${cell ?? ''}', width: columnWidths[columnIndex]!);
          }).toList();
          final linesCount = cellsLines.map((e) => e.length).max;

          final rowLines = <String>[];
          for (var lineIndex = 0; lineIndex < linesCount; lineIndex++) {
            final rowLine = <String>[];
            for (var columnIndex = 0; columnIndex < cellsLines.length; columnIndex++) {
              final cellLines = cellsLines[columnIndex];
              final columnWidth = columnWidths[columnIndex]!;
              rowLine.add(lineIndex < cellLines.length ? cellLines[lineIndex] : ' ' * columnWidth);
            }
            rowLines.add(rowLine.join(verticalDivisor));
          }

          return rowLines.join('\n');
        })
        .join('\n');
  }
}
