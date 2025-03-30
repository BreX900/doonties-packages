import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class MekTheme {
  static ColorScheme buildColorScheme(BuildContext context, [Color? primary, Color? secondary]) {
    const luminance = 0.5;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    primary ??= Colors.amber;
    secondary ??= Colors.yellow;

    final surface = isDark ? Colors.black : Colors.white;
    final onSurface = isDark ? Colors.white : Colors.black;

    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: primary.computeLuminance() > luminance ? Colors.black : Colors.white,
      secondary: secondary,
      onSecondary: secondary.computeLuminance() > luminance ? Colors.black : Colors.white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurface,
      surfaceTint: isDark ? const Color(0xff161616) : const Color(0xfff0f0f0),
      surfaceContainer: isDark ? const Color(0xff242424) : const Color(0xffe9e9e9),
      error: Colors.red[700]!,
      onError: isDark ? Colors.black : Colors.white,
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
        backgroundColor: colorScheme.surfaceContainer,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: colorScheme.secondaryContainer,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        errorMaxLines: 5,
      ),
      // ignore: deprecated_member_use
      dialogBackgroundColor: colorScheme.surfaceContainer,
      dialogTheme: DialogTheme(backgroundColor: colorScheme.surfaceContainer),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS:
              kIsWeb ? _HorizontalPageTransitionsBuilder() : CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceTint,
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
