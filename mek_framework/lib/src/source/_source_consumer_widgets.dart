part of 'source.dart';

class SourceConsumer extends SourceConsumerStatefulWidget {
  final Widget Function(BuildContext context, WidgetRef ref, WidgetScope scope, Widget? child) builder;

  const SourceConsumer({super.key, required this.builder});

  Widget build(BuildContext context, WidgetRef ref, WidgetScope scope) => builder(context, ref, scope, null);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

abstract class SourceConsumerWidget extends SourceConsumerStatefulWidget {
  const SourceConsumerWidget({super.key});

  Widget build(BuildContext context, WidgetRef ref, WidgetScope scope);

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState() => _SourceConsumerState();
}

class _SourceConsumerState extends SourceConsumerState<SourceConsumerWidget> {
  @override
  Widget build(BuildContext context) => widget.build(context, ref, scope);
}

abstract class SourceConsumerStatefulWidget extends ConsumerStatefulWidget {
  const SourceConsumerStatefulWidget({super.key});

  @override
  SourceConsumerState<SourceConsumerStatefulWidget> createState();

  @override
  // ignore: invalid_use_of_internal_member
  ConsumerStatefulElement createElement() => _SourceConsumerStatefulElement(this);
}

abstract class SourceConsumerState<T extends SourceConsumerStatefulWidget>
    extends ConsumerState<T> {
  late final WidgetScope scope = WidgetScope._(context as _SourceConsumerStatefulElement);
}

// ignore: invalid_use_of_internal_member
final class _SourceConsumerStatefulElement extends ConsumerStatefulElement
    with _SourceStatefulElementMixin {
  _SourceConsumerStatefulElement(SourceConsumerStatefulWidget super.widget);
}
