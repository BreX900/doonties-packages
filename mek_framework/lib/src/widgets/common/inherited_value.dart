import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

extension InheritedValueBuildContextExtension on BuildContext {
  T watch<T>() => InheritedValue.of<T>(this);
}

class InheritedValue<T> extends InheritedWidget implements SingleChildWidget {
  final T value;

  const InheritedValue({
    super.key,
    required this.value,
    super.child = const SizedBox.shrink(),
  });

  static T of<T>(BuildContext context) {
    final widget = _maybeWidgetOf<T>(context);
    if (widget == null) {
      throw ArgumentError('InheritedValue widget not exist on widget tree with type $T');
    }
    return widget.value;
  }

  static T? maybeOf<T>(BuildContext context) => _maybeWidgetOf(context)?.value;

  static InheritedValue<T>? _maybeWidgetOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedValue<T>>();
  }

  @override
  bool updateShouldNotify(InheritedValue<T> oldWidget) => value != oldWidget.value;

  @override
  // ignore: use_to_and_as_if_applicable
  SingleChildInheritedElementMixin createElement() => _InheritedDataElement(this);
}

class _InheritedDataElement extends InheritedElement
    with SingleChildWidgetElementMixin, SingleChildInheritedElementMixin {
  _InheritedDataElement(super.widget);
}
