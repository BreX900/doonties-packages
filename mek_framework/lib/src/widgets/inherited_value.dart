import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

extension InheritedValueBuildContextExtension on BuildContext {
  T watch<T extends Object>() => InheritedValue.of<T>(this);
}

class InheritedValue<T extends Object> extends InheritedWidget implements SingleChildWidget {
  final T value;

  const InheritedValue({
    super.key,
    required this.value,
    super.child = const SizedBox.shrink(),
  });

  static T of<T extends Object>(BuildContext context) {
    final value = maybeOf<T>(context);
    if (value == null) {
      throw ArgumentError('InheritedValue widget not exist on widget tree with type $T');
    }
    return value;
  }

  static T? maybeOf<T extends Object>(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<InheritedValue<T>>();
    return widget?.value;
  }

  @override
  bool updateShouldNotify(InheritedValue<T> oldWidget) => value != oldWidget.value;

  @override
  SingleChildInheritedElementMixin createElement() => _InheritedDataElement(this);
}

class _InheritedDataElement extends InheritedElement
    with SingleChildWidgetElementMixin, SingleChildInheritedElementMixin {
  _InheritedDataElement(super.widget);
}
