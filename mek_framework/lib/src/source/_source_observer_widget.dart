part of 'source.dart';

final class ConsumerScope extends SourceScope {
  WidgetRef get ref => _element as WidgetRef;

  ConsumerScope._(_SourceConsumerStatefulElement super._element) : super._();
}

class SourceConsumer extends SourceConsumerStatefulWidget {
  final Widget Function(BuildContext context, ConsumerScope scope, Widget? child) builder;

  const SourceConsumer({super.key, required this.builder});

  Widget build(BuildContext context, ConsumerScope scope) => builder(context, scope, null);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

abstract class SourceConsumerWidget extends SourceConsumerStatefulWidget {
  const SourceConsumerWidget({super.key});

  Widget build(BuildContext context, ConsumerScope scope);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

class _SourceConsumerState extends SourceConsumerState<SourceConsumerWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, scope);
}

abstract class SourceConsumerStatefulWidget extends ConsumerStatefulWidget {
  const SourceConsumerStatefulWidget({super.key});

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState();

  @override
  ConsumerStatefulElement createElement() => _SourceConsumerStatefulElement(this);
}

abstract class SourceConsumerState<T extends SourceConsumerStatefulWidget>
    extends ConsumerState<T> {
  late final ConsumerScope scope = ConsumerScope._(context as _SourceConsumerStatefulElement);
}

final class _SourceConsumerStatefulElement extends ConsumerStatefulElement
    with _SourceStatefulElementMixin {
  _SourceConsumerStatefulElement(SourceConsumerStatefulWidget super.widget);
}
