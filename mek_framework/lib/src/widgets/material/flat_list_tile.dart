import 'package:flutter/material.dart';

class DropdownListTileMenuItem<T> extends DropdownMenuItem<T> {
  DropdownListTileMenuItem({
    super.key,
    super.onTap,
    super.value,
    super.enabled = true,
    super.alignment,
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
  }) : super(
          child: ListTileLayout(
            leading: leading != null
                ? Builder(builder: (context) {
                    final textStyle = DefaultTextStyle.of(context);
                    final textScaler = MediaQuery.textScalerOf(context);

                    return IconTheme.merge(
                      data: IconThemeData(
                        color: textStyle.style.color,
                        size: textScaler.scale(textStyle.style.fontSize ?? kDefaultFontSize) *
                            (textStyle.style.height ?? 1.0),
                      ),
                      child: leading,
                    );
                  })
                : null,
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
        );
}

class ListTileLayout extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const ListTileLayout({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8.0)],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              if (subtitle != null) subtitle!,
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ParagraphTile extends StatelessWidget {
  final bool dense;
  final Color? color;
  final Color? textColor;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const ParagraphTile({
    super.key,
    this.dense = false,
    this.color,
    this.textColor,
    this.onTap,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: dense
            ? const BoxConstraints(minHeight: kMinInteractiveDimension / 2)
            : const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListTileLayout(
            leading: leading != null
                ? ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: kMinInteractiveDimension,
                      minHeight: kMinInteractiveDimension,
                    ),
                    child: Center(
                      child: DefaultTextStyle(
                        style: textTheme.bodyMedium!.copyWith(color: textColor ?? color),
                        child: leading!,
                      ),
                    ),
                  )
                : null,
            title: DefaultTextStyle(
              style: (dense ? textTheme.titleMedium : textTheme.titleLarge)!
                  .copyWith(color: textColor ?? color),
              child: title,
            ),
            subtitle: subtitle != null
                ? DefaultTextStyle(
                    style: textTheme.titleMedium!.copyWith(color: textColor ?? color),
                    child: subtitle!,
                  )
                : null,
            trailing: trailing != null
                ? DefaultTextStyle(
                    style: textTheme.bodyMedium!.copyWith(color: textColor ?? color),
                    child: trailing!,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class FlatListTile extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool enabled;
  final bool selected;
  final bool dense;
  final ListTileStyle? style;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final Color? textColor;
  final Color? selectedColor;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  const FlatListTile({
    super.key,
    this.style,
    this.enabled = true,
    this.selected = false,
    this.dense = false,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.textColor,
    this.selectedColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    this.onTap,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileTheme = ListTileTheme.of(context);
    final listTileStyle =
        style ?? tileTheme.style ?? theme.listTileTheme.style ?? ListTileStyle.list;
    final defaults = theme.useMaterial3
        ? _LisTileDefaultsM3(context)
        : _LisTileDefaultsM2(context, listTileStyle);

    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (selected) WidgetState.selected,
    };
    Color? resolveColor(Color? explicitColor, Color? selectedColor, Color? enabledColor,
        [Color? disabledColor]) {
      return _IndividualOverrides(
        explicitColor: explicitColor,
        selectedColor: selectedColor,
        enabledColor: enabledColor,
        disabledColor: disabledColor,
      ).resolve(states);
    }

    final effectiveColor = resolveColor(textColor, selectedColor, textColor) ??
        resolveColor(tileTheme.textColor, tileTheme.selectedColor, tileTheme.textColor) ??
        resolveColor(theme.listTileTheme.textColor, theme.listTileTheme.selectedColor,
            theme.listTileTheme.textColor) ??
        resolveColor(
            defaults.textColor, defaults.selectedColor, defaults.textColor, theme.disabledColor);

    var titleStyle = titleTextStyle ?? tileTheme.titleTextStyle ?? defaults.titleTextStyle!;
    final titleColor = effectiveColor;
    titleStyle = titleStyle.copyWith(color: titleColor, fontSize: dense ? 13.0 : null);
    final title = AnimatedDefaultTextStyle(
      style: titleStyle,
      duration: kThemeChangeDuration,
      child: this.title,
    );

    Widget? subtitle;
    if (this.subtitle != null) {
      var subtitleStyle =
          subtitleTextStyle ?? tileTheme.subtitleTextStyle ?? defaults.subtitleTextStyle!;
      final subtitleColor = effectiveColor;
      subtitleStyle = subtitleStyle.copyWith(color: subtitleColor, fontSize: dense ? 11.0 : null);
      subtitle = AnimatedDefaultTextStyle(
        style: subtitleStyle,
        duration: kThemeChangeDuration,
        child: this.subtitle!,
      );
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: ListTileLayout(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        ),
      ),
    );
  }
}

class _IndividualOverrides extends WidgetStateProperty<Color?> {
  _IndividualOverrides({
    this.explicitColor,
    this.enabledColor,
    this.selectedColor,
    this.disabledColor,
  });

  final Color? explicitColor;
  final Color? enabledColor;
  final Color? selectedColor;
  final Color? disabledColor;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (explicitColor is WidgetStateColor) {
      return WidgetStateProperty.resolveAs<Color?>(explicitColor, states);
    }
    if (states.contains(WidgetState.disabled)) {
      return disabledColor;
    }
    if (states.contains(WidgetState.selected)) {
      return selectedColor;
    }
    return enabledColor;
  }
}

class _LisTileDefaultsM2 extends ListTileThemeData {
  _LisTileDefaultsM2(this.context, ListTileStyle style)
      : super(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          minLeadingWidth: 40,
          minVerticalPadding: 4,
          shape: const Border(),
          style: style,
        );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get tileColor => Colors.transparent;

  @override
  TextStyle? get titleTextStyle {
    switch (style!) {
      case ListTileStyle.drawer:
        return _textTheme.bodyLarge;
      case ListTileStyle.list:
        return _textTheme.titleMedium;
    }
  }

  @override
  TextStyle? get subtitleTextStyle =>
      _textTheme.bodyMedium!.copyWith(color: _textTheme.bodySmall!.color);

  @override
  TextStyle? get leadingAndTrailingTextStyle => _textTheme.bodyMedium;

  @override
  Color? get selectedColor => _theme.colorScheme.primary;

  @override
  Color? get iconColor {
    switch (_theme.brightness) {
      case Brightness.light:
        // For the sake of backwards compatibility, the default for unselected
        // tiles is Colors.black45 rather than colorScheme.onSurface.withAlpha(0x73).
        return Colors.black45;
      case Brightness.dark:
        return null; // null, Use current icon theme color
    }
  }
}

// BEGIN GENERATED TOKEN PROPERTIES - LisTile

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

class _LisTileDefaultsM3 extends ListTileThemeData {
  _LisTileDefaultsM3(this.context)
      : super(
          contentPadding: const EdgeInsetsDirectional.only(start: 16.0, end: 24.0),
          minLeadingWidth: 24,
          minVerticalPadding: 8,
          shape: const RoundedRectangleBorder(),
        );

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;
  late final TextTheme _textTheme = _theme.textTheme;

  @override
  Color? get tileColor => Colors.transparent;

  @override
  TextStyle? get titleTextStyle => _textTheme.bodyLarge!.copyWith(color: _colors.onSurface);

  @override
  TextStyle? get subtitleTextStyle =>
      _textTheme.bodyMedium!.copyWith(color: _colors.onSurfaceVariant);

  @override
  TextStyle? get leadingAndTrailingTextStyle =>
      _textTheme.labelSmall!.copyWith(color: _colors.onSurfaceVariant);

  @override
  Color? get selectedColor => _colors.primary;

  @override
  Color? get iconColor => _colors.onSurfaceVariant;
}

// END GENERATED TOKEN PROPERTIES - LisTile
