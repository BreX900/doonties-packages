import 'package:flutter/material.dart';

class SliverPersistentPreferredSizeHeader extends StatelessWidget {
  final bool pinned;
  final bool floating;
  final PreferredSizeWidget child;

  const SliverPersistentPreferredSizeHeader({
    super.key,
    this.pinned = false,
    this.floating = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _SliverPersistentPreferredSizeHeaderDelegate(child: child),
    );
  }
}

class _SliverPersistentPreferredSizeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;

  const _SliverPersistentPreferredSizeHeaderDelegate({
    required this.child,
  });

  double get height => child.preferredSize.height;

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
