import 'package:flutter/material.dart';

class HarmonicScaffold extends StatelessWidget {
  bool get resizeToAvoidBottomInset => true;
  final PreferredSizeWidget? appBar;
  final Widget floatingActionButton;
  final Widget body;

  const HarmonicScaffold({
    super.key,
    this.appBar,
    required this.floatingActionButton,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Builder(builder: (context) {
        final metrics = MediaQuery.of(context);
        return MediaQuery(
          data: metrics.copyWith(
            viewPadding: metrics.viewPadding + const EdgeInsets.only(bottom: 64.0 + 16.0),
          ),
          child: body,
        );
      }),
    );
  }
}
