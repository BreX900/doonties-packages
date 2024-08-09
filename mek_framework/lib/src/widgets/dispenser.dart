import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

class InheritedValue<T extends Object> extends InheritedWidget implements SingleChildWidget {
  final T data;

  const InheritedValue({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedValue<T> oldWidget) => data != oldWidget.data;

  @override
  // ignore: library_private_types_in_public_api
  _InheritedValueElement createElement() => _InheritedValueElement(this);
}

class _InheritedValueElement extends InheritedElement
    with SingleChildWidgetElementMixin, SingleChildInheritedElementMixin {
  _InheritedValueElement(super.widget);
}
