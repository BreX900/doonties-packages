import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class BuiltFormTheme extends ThemeExtension<BuiltFormTheme> with EquatableMixin {
  final EdgeInsetsGeometry? fieldPadding;

  const BuiltFormTheme({
    this.fieldPadding,
  });

  static BuiltFormTheme of(BuildContext context) {
    final result = Theme.of(context).extension<BuiltFormTheme>();
    // assert(result != null, 'No BuiltFormTheme found in context');
    return result ?? const BuiltFormTheme();
  }

  Widget wrap({EdgeInsetsGeometry? padding, required Widget child}) {
    padding ??= fieldPadding;
    if (padding == null) return child;
    return Padding(
      padding: padding,
      child: child,
    );
  }

  @override
  List<Object?> get props => [fieldPadding];

  @override
  BuiltFormTheme copyWith() => this;

  @override
  BuiltFormTheme lerp(covariant BuiltFormTheme? other, double t) => this;
}
