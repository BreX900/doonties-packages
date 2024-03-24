import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mek/mek.dart';

abstract class MekTheme {
  static ColorScheme buildColorScheme() {
    final brightness = PlatformDispatcher.instance.platformBrightness;
    const colorPrimary = Colors.amber;
    const colorSecondary = Colors.yellow;

    return ColorScheme.fromSeed(
      seedColor: colorPrimary,
      brightness: brightness,
      background: brightness == Brightness.light ? null : Colors.black,
      primary: colorPrimary,
      onPrimary: Colors.black,
      secondary: colorSecondary,
      onSecondary: Colors.black,
    );
  }

  static ThemeData build({
    ColorScheme? colorScheme,
  }) {
    colorScheme ??= buildColorScheme();

    final platform = defaultTargetPlatform;
    const buttonSize = Size(kMinInteractiveDimension * 3, kMinInteractiveDimension);

    return ThemeData.from(
      useMaterial3: true,
      colorScheme: colorScheme,
    ).copyWith(
      canvasColor: colorScheme.brightness == Brightness.light ? null : const Color(0xff121212),
      // textTheme: Typography.tall2018.apply(fontSizeFactor: 1.1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
        ),
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
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: colorScheme.secondaryContainer,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        errorMaxLines: 5,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS:
              kIsWeb ? _HorizontalPageTransitionsBuilder() : CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: {
        const BuiltFormTheme(
          fieldPadding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
      },
    );
  }
}

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
