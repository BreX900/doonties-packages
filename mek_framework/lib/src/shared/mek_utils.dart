import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';

typedef ProgressEmitter = void Function(double value);

abstract final class MekUtils {
  static void showSnackBarError({
    required BuildContext context,
    required Widget description,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final backgroundColor = colors.errorContainer;
    final foregroundColor = colors.onErrorContainer;

    final progressController = AnimationController(
      vsync: scaffoldMessenger,
      duration: const Duration(seconds: 5),
    );

    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;
    controller = scaffoldMessenger.showSnackBar(SnackBar(
      padding: EdgeInsets.zero,
      duration: const Duration(minutes: 5),
      showCloseIcon: false,
      closeIconColor: foregroundColor,
      backgroundColor: backgroundColor,
      onVisible: () async => progressController.forward().whenComplete(controller.close),
      content: _ErrorSnackBarContent(
        autoCloseController: progressController,
        foregroundColor: foregroundColor,
        child: description,
      ),
    ));

    unawaited(controller.closed.whenComplete(progressController.dispose));
  }

  @Deprecated('In favour of process')
  static Future<void> processAll(
    ProgressEmitter progressEmitter,
    List<Future<void> Function(ProgressEmitter)> tasks,
  ) async {
    return process(progressEmitter, tasks.toIList(), (task, emitProgress) => task(emitProgress));
  }

  static Future<void> process<T>(
    ProgressEmitter progressEmitter,
    IList<T> elements,
    Future<void> Function(T element, ProgressEmitter emitProgress) tasker,
  ) async {
    for (var i = 0; i < elements.length; i++) {
      void emitTaskProgress(double value) {
        progressEmitter(i / elements.length + 1 / elements.length * value);
      }

      await tasker(elements[i], emitTaskProgress);
      emitTaskProgress(1.0);
    }
    progressEmitter(1.0);
  }

  @Deprecated('In favour of processParallel')
  static Future<void> processAllParallel(
    ProgressEmitter progressEmitter,
    Iterable<Future<void> Function(ProgressEmitter)> tasks,
  ) {
    return processParallel(progressEmitter, tasks, (task, emitProgress) => task(emitProgress));
  }

  static Future<void> processParallel<T>(
    ProgressEmitter progressEmitter,
    Iterable<T> elements,
    Future<void> Function(T element, ProgressEmitter emitProgress) tasker,
  ) async {
    final progresses = <int, double>{};
    var elementsCount = 0;
    await Future.wait(elements.mapIndexed((index, element) async {
      elementsCount += 1;

      void emitTaskProgress(double value) {
        progresses[index] = value;
        progressEmitter(progresses.values.sum / elementsCount);
      }

      await tasker(element, emitTaskProgress);
      emitTaskProgress(1.0);
    }));
  }

  static RelativeRect getMenuPosition(BuildContext context, Offset offset) {
    final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final renderBox = context.findRenderObject()! as RenderBox;

    final startBoxOffset = renderBox.localToGlobal(offset, ancestor: overlay);
    final endBoxOffset =
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero), ancestor: overlay);

    return RelativeRect.fromLTRB(
      startBoxOffset.dx,
      startBoxOffset.dy,
      endBoxOffset.dx,
      endBoxOffset.dy,
    );
  }

  static Iterable<T> search<T>(
    Iterable<T> elements,
    String text,
    String Function(T element) hash,
  ) sync* {
    final words = text.toLowerCase().split(' ');
    for (final element in elements) {
      final elementText = hash(element).toLowerCase();
      if (words.every(elementText.contains)) yield element;
    }
  }

  static List<T> Function(String text) handleSuggestions<T>(
    Iterable<T> elements,
    String Function(T element) hash,
  ) {
    return (text) => search(elements, text, hash).toList();
  }
}

class _ErrorSnackBarContent extends StatelessWidget {
  final AnimationController autoCloseController;
  final Color foregroundColor;
  final Widget child;

  const _ErrorSnackBarContent({
    required this.autoCloseController,
    required this.foregroundColor,
    required this.child,
  });

  void _stopAutoClose() {
    autoCloseController.value = 0.0;
  }

  void _close(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _stopAutoClose,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 14.0, 0.0, 14.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.error_outline, color: foregroundColor),
                ),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: foregroundColor),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    child: child,
                  ),
                ),
                IconButton(
                  onPressed: () => _close(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedBuilder(
              animation: autoCloseController,
              builder: (context, _) {
                if (autoCloseController.value == 0.0) return const SizedBox.shrink();
                return LinearProgressIndicator(value: autoCloseController.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
