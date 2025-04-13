import 'package:flutter/material.dart';

class HarmonicScaffold extends StatelessWidget {
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? body;

  const HarmonicScaffold({
    super.key,
    this.resizeToAvoidBottomInset = true,
    this.appBar,
    this.floatingActionButton,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    final body = this.body;
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: body != null
          ? Builder(builder: (context) {
              final metrics = MediaQuery.of(context);
              return MediaQuery(
                data: metrics.copyWith(
                  viewPadding: metrics.viewPadding + const EdgeInsets.only(bottom: 64.0 + 16.0),
                ),
                child: body,
              );
            })
          : null,
    );
  }
}
