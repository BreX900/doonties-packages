import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mek/mek.dart';

class MekColumn extends StatelessWidget {
  final TableColumnWidth columnWidth;
  final Widget label;

  const MekColumn({
    super.key,
    this.columnWidth = const IntrinsicColumnWidth(),
    required this.label,
  });

  @override
  Widget build(BuildContext context) => label;
}

class MekRow {
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSecondaryTap;
  final ValueChanged<bool>? onSelectChanged;
  final bool selected;
  final List<Widget> children;

  bool get isSelected => false;

  bool get isDisabled => false;

  const MekRow({
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.onSelectChanged,
    this.selected = false,
    required this.children,
  });

  bool get hasGestures =>
      onTap != null || onDoubleTap != null || onSecondaryTap != null || onSelectChanged != null;
}

class MekTable extends StatelessWidget {
  /// The default height of the heading row.
  static const double _headingRowHeight = 56.0;

  /// The default horizontal margin between the edges of the table and the content
  /// in the first and last cells of each row.
  static const double _horizontalMargin = 12.0; // 24

  /// The default horizontal margin between the contents of each data column.
  static const double _columnSpacing = 30.0; // 56.0

  /// The default divider thickness.
  static const double _dividerThickness = 1.0;

  final ValueSetter<bool>? onSelectAll;
  final List<MekColumn> columns;
  final List<MekRow> rows;

  const MekTable({super.key, this.onSelectAll, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataTableTheme = DataTableTheme.of(context);

    final effectiveHorizontalMargin =
        dataTableTheme.horizontalMargin ??
        theme.dataTableTheme.horizontalMargin ??
        _horizontalMargin;
    final effectiveColumnSpacing =
        dataTableTheme.columnSpacing ?? theme.dataTableTheme.columnSpacing ?? _columnSpacing;

    // DataTable._buildHeadingCell
    final effectiveHeadingTextStyle =
        dataTableTheme.headingTextStyle ??
        theme.dataTableTheme.headingTextStyle ??
        theme.textTheme.titleSmall!;
    final effectiveHeadingRowHeight =
        dataTableTheme.headingRowHeight ??
        theme.dataTableTheme.headingRowHeight ??
        _headingRowHeight;

    // DataTable._buildDataCell
    final effectiveDataTextStyle =
        dataTableTheme.dataTextStyle ??
        theme.dataTableTheme.dataTextStyle ??
        theme.textTheme.bodyMedium!;
    final effectiveDataRowMinHeight =
        dataTableTheme.dataRowMinHeight ??
        theme.dataTableTheme.dataRowMinHeight ??
        kMinInteractiveDimension;
    final effectiveDataRowMaxHeight =
        dataTableTheme.dataRowMaxHeight ??
        theme.dataTableTheme.dataRowMaxHeight ??
        kMinInteractiveDimension;

    EdgeInsetsGeometry resolvePadding({required bool isFirst, required bool isLast}) {
      return EdgeInsetsDirectional.only(
        start: isFirst ? effectiveColumnSpacing : effectiveHorizontalMargin,
        end: isLast ? effectiveColumnSpacing : effectiveHorizontalMargin,
      );
    }

    final effectiveDataRowColor = dataTableTheme.dataRowColor ?? theme.dataTableTheme.dataRowColor;
    final defaultRowColor = WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return theme.colorScheme.primary.withValues(alpha: 0.08);
      }
      return null;
    });
    final borderSide = Divider.createBorderSide(
      context,
      width:
          dataTableTheme.dividerThickness ??
          theme.dataTableTheme.dividerThickness ??
          _dividerThickness,
    );
    final border = Border(top: borderSide);

    final hasCheckboxColumn = rows.any((e) => e.onSelectChanged != null);

    final columns = <MekColumn>[
      if (hasCheckboxColumn)
        MekColumn(
          label: onSelectAll != null
              ? Checkbox(
                  value: rows.every((e) => e.selected),
                  onChanged: (value) => onSelectAll!(value!),
                )
              : const SizedBox.shrink(),
        ),

      ...this.columns,
    ];

    return Table(
      columnWidths: columns.map((column) => column.columnWidth).toList().asMap(),
      children: [
        TableRow(
          decoration: rows.isEmpty
              ? BoxDecoration(
                  border: Border(bottom: borderSide),
                  color:
                      effectiveDataRowColor?.resolve(const {}) ?? defaultRowColor.resolve(const {}),
                )
              : null,
          children: columns.map((e) {
            final isFirst = e == columns.first;
            final isLast = e == columns.last;

            return Container(
              padding: resolvePadding(isFirst: isFirst, isLast: isLast),
              height: effectiveHeadingRowHeight,
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle(style: effectiveHeadingTextStyle, child: e),
            );
          }).toList(),
        ),
        ...rows.map((row) {
          final states = <WidgetState>{
            if (row.isSelected) WidgetState.selected,
            if (row.isDisabled) WidgetState.disabled,
          };

          final children = [
            if (hasCheckboxColumn)
              if (row.onSelectChanged case final onSelectChanged?)
                Checkbox(value: row.selected, onChanged: (value) => onSelectChanged(value!))
              else
                const SizedBox.shrink(),
            ...row.children,
          ];

          return TableRow(
            decoration: BoxDecoration(
              border: border,
              color: effectiveDataRowColor?.resolve(states) ?? defaultRowColor.resolve(states),
            ),
            children: children.map((e) {
              final isFirst = e == children.first;
              final isLast = e == children.last;

              Widget child = Container(
                padding: resolvePadding(isFirst: isFirst, isLast: isLast),
                constraints: BoxConstraints(
                  minHeight: effectiveDataRowMinHeight,
                  maxHeight: effectiveDataRowMaxHeight,
                ),
                alignment: AlignmentDirectional.centerStart,
                child: DefaultTextStyle(style: effectiveDataTextStyle, child: e),
              );

              if (row.hasGestures) {
                child = TableRowInkWell(
                  onTap: isFirst && row.onSelectChanged != null
                      ? () => row.onSelectChanged!(!row.selected)
                      : row.onTap,
                  onDoubleTap: row.onDoubleTap,
                  onSecondaryTap: row.onSecondaryTap,
                  child: child,
                );
              }
              return child;
            }).toList(),
          );
        }),
      ],
    );

    // final children = <Widget>[table, if (rows.isEmpty) const Text('🪫 No Data 🪫')];
    //
    // if (children.length == 1) return children.single;
    //
    // return Column(children: children);
  }
}

class MekTablePagination extends ConsumerWidget {
  final CursorBloc cursorBloc;

  const MekTablePagination({super.key, required this.cursorBloc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursorState = ref.watch(cursorBloc.provider);

    final localizations = MaterialLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          padding: EdgeInsets.zero,
          tooltip: localizations.previousPageTooltip,
          onPressed: cursorState.isPageFirst ? null : cursorBloc.moveToPrevious,
        ),
        const SizedBox(width: 24.0),
        Text('Page: ${cursorState.page + 1}'),
        const SizedBox(width: 24.0),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          padding: EdgeInsets.zero,
          tooltip: localizations.nextPageTooltip,
          onPressed: cursorState.isPageLast ? null : cursorBloc.moveToNext,
        ),
      ],
    );
  }
}
