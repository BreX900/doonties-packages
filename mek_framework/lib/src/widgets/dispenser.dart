import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

abstract interface class Dispensable {
  Widget buildDispenser(Widget child);
}

abstract class DispensableEquatable<T extends DispensableEquatable<T>> extends Equatable
    implements Dispensable {
  const DispensableEquatable();

  @override
  bool? get stringify => true;

  @override
  Widget buildDispenser(Widget child) => SingleDispenser<T>(data: this as T, child: child);
}

class Dispense<T extends Object> implements Dispensable {
  final T data;

  const Dispense.value(this.data);

  static T of<T extends Object>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SingleDispenser<T>>();
    assert(result != null, 'No Dispenser<$T> found in context');
    return result!.data;
  }

  static T? maybeOf<T extends Object>(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<SingleDispenser<T>>();
    return result?.data;
  }

  @override
  Widget buildDispenser(Widget child) {
    // ignore: prefer_asserts_with_message
    assert(T != Object);
    return SingleDispenser<T>(data: data, child: child);
  }
}

class SingleDispenser<T extends Object> extends InheritedWidget {
  final T data;

  const SingleDispenser({
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(SingleDispenser<T> oldWidget) => data != oldWidget.data;
}

class MultiDispenser extends StatelessWidget {
  final List<Dispensable> dispensable;
  final Widget child;

  const MultiDispenser({
    super.key,
    required this.dispensable,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var child = this.child;
    for (final dispenser in dispensable.reversed) {
      child = dispenser.buildDispenser(child);
    }
    return child;
  }
}
