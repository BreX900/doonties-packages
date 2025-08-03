import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class MekTheme {
  static ColorScheme buildColorScheme(BuildContext context, [Color? primary, Color? secondary]) {
    const luminance = 0.5;
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    primary ??= Colors.amber;
    secondary ??= Colors.yellow;

    final surface = isDark ? const Color(0xff121212) : Colors.white;
    final onSurface = isDark ? Colors.white : Colors.black;

    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: primary.computeLuminance() > luminance ? Colors.black : Colors.white,
      secondary: secondary,
      onSecondary: secondary.computeLuminance() > luminance ? Colors.black : Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceTint: Colors.white,
      onSurfaceVariant: onSurface,
      surfaceContainer: isDark ? const Color(0xff181818) : const Color(0xfff0f0f0),
      surfaceContainerLowest: isDark ? const Color(0xff242424) : const Color(0xffe9e9e9),
      secondaryContainer: secondary,
      error: isDark ? const Color(0xffcf6679) : const Color(0xffb00020),
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
        surfaceTintColor: colorScheme.surfaceContainer,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: colorScheme.secondaryContainer,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        errorMaxLines: 5,
        contentPadding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 8.0),
      ),
      // ignore: deprecated_member_use
      dialogBackgroundColor: colorScheme.surfaceContainer,
      dialogTheme: DialogThemeData(backgroundColor: colorScheme.surfaceContainer),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS:
              kIsWeb ? _HorizontalPageTransitionsBuilder() : CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        actionBackgroundColor: colorScheme.primary,
        actionTextColor: colorScheme.onPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primary,
      ),
      tabBarTheme: TabBarThemeData(
        dividerHeight: 0.0,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: UnderlineTabIndicator(
          insets: const EdgeInsets.symmetric(horizontal: 4.0),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          borderSide: BorderSide(color: colorScheme.primary, width: 3.0),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        linearTrackColor: Colors.transparent,
      ),
      sliderTheme: SliderThemeData(
        inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
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
