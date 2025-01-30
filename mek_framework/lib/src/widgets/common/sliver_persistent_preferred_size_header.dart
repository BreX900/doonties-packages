import 'package:flutter/material.dart';

class SliverPersistentSizeHeader extends StatelessWidget {
  final bool pinned;
  final bool floating;
  final double height;
  final Widget child;

  const SliverPersistentSizeHeader({
    super.key,
    this.pinned = false,
    this.floating = false,
    required this.height,
    required this.child,
  });

  SliverPersistentSizeHeader.preferred({
    super.key,
    this.pinned = false,
    this.floating = false,
    required PreferredSizeWidget this.child,
  }) : height = child.preferredSize.height;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _SliverPersistentPreferredSizeHeaderDelegate(
        height: height,
        child: child,
      ),
    );
  }
}

class _SliverPersistentPreferredSizeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _SliverPersistentPreferredSizeHeaderDelegate({
    required this.height,
    required this.child,
  });

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverPersistentPreferredSizeHeaderDelegate oldDelegate) =>
      height != oldDelegate.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      elevation: shrinkOffset / height * 3.0,
      color: colors.surface,
      surfaceTintColor: colors.surfaceTint,
      child: child,
    );
  }
}
