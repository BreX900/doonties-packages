import 'package:flutter/material.dart';

extension HubOnBuildContext on BuildContext {
  Nav get nav => Nav._(Navigator.of(this));
}

class Nav {
  final NavigatorState _navigator;

  Nav._(this._navigator);

  @optionalTypeArgs
  void pop<T>([T? result]) => _navigator.pop<T>(result);

  @optionalTypeArgs
  Future<T?> push<T>(Widget screen) {
    return _navigator.push<T>(_createPage(screen));
  }

  @optionalTypeArgs
  Future<T?> pushReplacement<T>(Widget screen) {
    return _navigator.pushReplacement(_createPage(screen));
  }

  Route<T> _createPage<T>(Widget screen) {
    return MaterialPageRoute(builder: (context) => screen);
  }
}

mixin TypedWidgetMixin<T> on Widget {
  void pop(BuildContext context, [T? result]) => Navigator.pop<T>(context, result);
}

Future<T?> showTypedDialog<T>({
  required BuildContext context,
  required TypedWidgetMixin<T> Function(BuildContext context) builder,
}) async {
  return await showDialog(
    context: context,
    builder: builder,
  );
}
