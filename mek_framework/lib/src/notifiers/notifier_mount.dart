import 'package:flutter/foundation.dart';

mixin NotifierMount on ChangeNotifier {
  var _mounted = true;

  @protected
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
}
