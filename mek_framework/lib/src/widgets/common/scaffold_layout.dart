import 'dart:math';

import 'package:flutter/widgets.dart';

class ScaffoldLayout extends StatelessWidget {
  final Widget body;
  final Widget bottomNavigationBar;

  const ScaffoldLayout({super.key, required this.body, required this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    final metrics = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, viewConstraints) {
        return Column(
          crossAxisAlignment: .stretch,
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, bodyConstraints) {
                  final consumedHeight = viewConstraints.maxHeight - bodyConstraints.maxHeight;

                  return MediaQuery(
                    data: metrics.copyWith(
                      padding: metrics.padding.copyWith(
                        bottom: max(metrics.padding.bottom - consumedHeight, 0.0),
                      ),
                      viewPadding: metrics.viewPadding.copyWith(
                        bottom: max(metrics.viewPadding.bottom - consumedHeight, 0.0),
                      ),
                      viewInsets: metrics.viewInsets.copyWith(
                        bottom: max(metrics.viewInsets.bottom - consumedHeight, 0.0),
                      ),
                    ),
                    child: body,
                  );
                },
              ),
            ),
            MediaQuery(
              data: metrics.copyWith(
                padding: metrics.viewPadding.copyWith(top: 0),
                viewPadding: metrics.viewPadding.copyWith(top: 0),
                viewInsets: .zero,
              ),
              child: bottomNavigationBar,
            ),
          ],
        );
      },
    );
  }
}
