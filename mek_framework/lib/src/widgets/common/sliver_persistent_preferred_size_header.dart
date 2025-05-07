import 'package:flutter/material.dart';

class SliverPersistentSizeHeader extends StatelessWidget {
  final bool pinned;
  final bool floating;
  final bool forceElevated;
  final double height;
  final Widget child;

  const SliverPersistentSizeHeader({
    super.key,
    this.pinned = false,
    this.floating = false,
    this.forceElevated = false,
    required this.height,
    required this.child,
  });

  SliverPersistentSizeHeader.preferred({
    super.key,
    this.pinned = false,
    this.floating = false,
    this.forceElevated = false,
    required PreferredSizeWidget this.child,
  }) : height = child.preferredSize.height;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _SliverPersistentPreferredSizeHeaderDelegate(
        forceElevated: forceElevated,
        height: height,
        child: child,
      ),
    );
  }
}

class _SliverPersistentPreferredSizeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool forceElevated;
  final double height;
  final Widget child;

  const _SliverPersistentPreferredSizeHeaderDelegate({
    required this.forceElevated,
    required this.height,
    required this.child,
  });

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _SliverPersistentPreferredSizeHeaderDelegate oldDelegate) =>
      forceElevated != oldDelegate.forceElevated ||
      height != oldDelegate.height ||
      child != oldDelegate.child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      elevation: forceElevated ? 3.0 : (shrinkOffset / height * 3.0),
      color: colors.surface,
      surfaceTintColor: colors.surfaceTint,
      child: child,
    );
  }
}
