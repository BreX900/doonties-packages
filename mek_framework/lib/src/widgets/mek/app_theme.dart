import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class MekTheme {
  static ColorScheme buildColorScheme(BuildContext context, [Color? color]) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;
    const colorPrimary = Colors.amber;
    const colorSecondary = Colors.yellow;

    final surface = isDark ? const Color(0xff121212) : Colors.white;
    final onSurface = isDark ? Colors.white : Colors.black;

    return ColorScheme.fromSeed(
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      seedColor: color ?? colorPrimary,
      brightness: brightness,
      primary: color == null ? colorPrimary : null,
      onPrimary: Colors.black,
      secondary: color == null ? colorSecondary : null,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurface,
    );
  }

  static ThemeData build({
    required BuildContext context,
    ColorScheme? colorScheme,
  }) {
    colorScheme ??= buildColorScheme(context);

    final platform = defaultTargetPlatform;
    const buttonSize = Size(kMinInteractiveDimension * 2, kMinInteractiveDimension);

    return ThemeData.from(
      useMaterial3: true,
      colorScheme: colorScheme,
    ).copyWith(
      canvasColor: colorScheme.surfaceContainerHigh,
      // textTheme: Typography.tall2018.apply(fontSizeFactor: 1.1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: buttonSize),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: buttonSize),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: buttonSize),
      ),
      listTileTheme: const ListTileThemeData(
        titleAlignment: ListTileTitleAlignment.center,
      ),
      popupMenuTheme: const PopupMenuThemeData(
        position: PopupMenuPosition.under,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: switch (platform) {
          TargetPlatform.android || TargetPlatform.iOS => false,
          _ => true,
        },
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: colorScheme.secondaryContainer,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        errorMaxLines: 5,
      ),
      dialogBackgroundColor: colorScheme.surfaceContainer,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS:
              kIsWeb ? _HorizontalPageTransitionsBuilder() : CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

extension CardThemeBorderRadiusExtension on CardThemeData {
  BorderRadius get borderRadius {
    assert(shape == null);
    return const BorderRadius.all(Radius.circular(12.0));
  }
}

extension FloatingActionSpace on FloatingActionButtonThemeData {
  double get standardFloatSpace =>
      kFloatingActionButtonMargin * 2 + (sizeConstraints?.maxHeight ?? 56.0);
}

// https://github.com/flutter/flutter/issues/114324#issuecomment-1725887254
class _HorizontalPageTransitionsBuilder extends PageTransitionsBuilder {
  const _HorizontalPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!route.isCurrent && !route.isActive) return const SizedBox.shrink();

    final primaryAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.fastEaseInToSlowEaseOut,
    ).drive(Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ));

    return SlideTransition(
      position: primaryAnimation,
      textDirection: Directionality.of(context),
      transformHitTests: false,
      child: child,
    );
  }
}
