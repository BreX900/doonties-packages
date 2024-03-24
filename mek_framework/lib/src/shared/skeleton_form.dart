import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mek/src/form/blocs/field_bloc.dart';
import 'package:mek/src/form/fields/field_builder.dart';

class SkeletonForm extends StatefulWidget {
  final VoidCallback? onSubmit;
  final Widget child;

  const SkeletonForm({
    super.key,
    this.onSubmit,
    required this.child,
  });

  static void requestNextFocusOrSubmit(
    BuildContext context, [
    FieldBuilderState<FieldBuilder<Object?>, Object?>? currentField,
  ]) {
    return _maybeOf(context)?.requestNextFocusOrSubmit(currentField);
  }

  static Future<void> requestFocusOnError(BuildContext context) async {
    var targetContext = context;
    final form = _maybeOf(targetContext);
    if (form != null) targetContext = form.context;

    final field = targetContext.inspectChildElements(_fieldInspector((field) {
      if (field.fieldBlocState.status.isInvalid) return field;
      return null;
    }));

    if (field == null) return;

    return Scrollable.ensureVisible(field.context);
  }

  static _SkeletonFormState? _maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<_SkeletonFormState>();
  }

  @override
  State<SkeletonForm> createState() => _SkeletonFormState();
}

class _SkeletonFormState extends State<SkeletonForm> {
  void requestNextFocusOrSubmit([FieldBuilderState<FieldBuilder<Object?>, Object?>? currentField]) {
    var findCurrentField = false;

    final field = context.inspectChildElements(_fieldInspector((field) {
      if (findCurrentField) return field;

      findCurrentField = currentField == field || field.focusNode.hasFocus;

      return null;
    }));

    if (!findCurrentField) {
      if (kDebugMode) print('Not found current field!');
      return;
    }

    if (field != null) {
      field.focusNode.requestFocus();
    } else {
      widget.onSubmit?.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

FieldBuilderState<FieldBuilder<Object?>, Object?>? Function(Element) _fieldInspector(
  FieldBuilderState<FieldBuilder<Object?>, Object?>? Function(
          FieldBuilderState<FieldBuilder<Object?>, Object?> state)
      inspector,
) {
  return (element) {
    if (element is! StatefulElement) return null;
    final state = element.state;
    if (state is! FieldBuilderState) return null;
    return inspector(state);
  };
}

extension on BuildContext {
  T? inspectChildElements<T extends Object>(T? Function(Element element) inspector) {
    T? result;
    void visitor(Element element) {
      if (result != null) return;
      result = inspector(element);
      element.visitChildren(visitor);
    }

    visitChildElements(visitor);
    return result;
  }
}
