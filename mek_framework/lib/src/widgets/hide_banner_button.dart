import 'package:flutter/material.dart';

class HideBannerButton extends StatelessWidget {
  const HideBannerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
      icon: const Icon(Icons.close),
    );
  }
}
