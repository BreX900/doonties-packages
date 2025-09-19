import 'dart:async';

import 'package:flutter/widgets.dart';

class DotsText extends StatefulWidget {
  const DotsText({super.key});

  static Widget or(String? text, {Key? key}) {
    if (text != null) {
      return Text(text);
    }
    return const DotsText();
  }

  @override
  State<DotsText> createState() => _DotsTextState();
}

class _DotsTextState extends State<DotsText> with TickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  var _text = '.';

  @override
  void initState() {
    super.initState();

    final animation = StepTween(begin: 1, end: 4).animate(_animationController);
    animation.addListener(() => _animate(animation.value));

    unawaited(_animationController.repeat());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animate(int value) {
    final text = '.' * value;
    if (_text == text) return;
    setState(() => _text = text);
  }

  @override
  Widget build(BuildContext context) => Text(_text);
}
