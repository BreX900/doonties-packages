// SliverPersistentHeader(
//   pinned: true,
//   floating: true,
//   // snap: true,
//   // title: Text('Ciao'),
//   delegate: _SliverPersistentHeaderDelegate(
//     child: TabBar(
//       tabs: [
//         Tab(text: 'Transactions'),
//         Tab(text: 'Graphs'),
//       ],
//     ),
//   ),
// ),
// SliverAppBar(
//   pinned: true,
//   floating: true,
//   expandedHeight: kToolbarHeight * 2,
//   title: Text('Ciao'),
//   flexibleSpace: _Ciao(
//     child: tabBar,
//   ),
// ),
// class _Ciao extends StatelessWidget {
//   final Widget child;
//
//   const _Ciao({
//     super.key,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
//
//     print(
//         'settings.minExtent: ${settings.minExtent} ${settings.currentExtent} ${settings.maxExtent}');
//
//     print(settings.currentExtent - settings.minExtent);
//
//     return Stack(
//       children: [
//         Positioned(
//           top: settings.minExtent,
//           right: 0.0,
//           left: 0.0,
//           height: settings.minExtent,
//           child: ClipRRect(
//             child: Transform.translate(
//               offset: Offset(0.0, settings.currentExtent - settings.maxExtent),
//               child: child,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final PreferredSizeWidget child;
//
//   const _SliverPersistentHeaderDelegate({
//     required this.child,
//   });
//
//   @override
//   double get maxExtent => child.preferredSize.height;
//
//   @override
//   double get minExtent => 0.0;
//
//   @override
//   bool shouldRebuild(covariant _SliverPersistentHeaderDelegate oldDelegate) {
//     return child != oldDelegate.child;
//   }
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//
//     print(shrinkOffset);
//
//     return Material(
//       elevation: shrinkOffset / child.preferredSize.height * 3.0,
//       color: colors.surface,
//       surfaceTintColor: colors.surfaceTint,
//       child: child,
//     );
//   }
// }
