import 'package:flutter/material.dart';

class NavigationDestinationBaril {
  final Widget icon;
  final String label;

  const NavigationDestinationBaril({
    required this.icon,
    required this.label,
  });
}

// TODO: Try this package https://pub.dev/packages/flutter_adaptive_scaffold
class NavigationBaril extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestinationBaril> destinations;
  final Widget child;

  const NavigationBaril({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
  });

  @override
  State<NavigationBaril> createState() => _NavigationBarilState();
}

class _NavigationBarilState extends State<NavigationBaril> {
  static const double _minWidth = 80.0;
  static const double _minExtendedWidth = 256.0;

  bool _canShowRail(Size size) {
    final aspectRatio = (size.width - _minWidth) / size.height;
    return aspectRatio >= 4 / 3;
  }

  bool _canExtendRail(Size size) {
    final aspectRatio = (size.width - _minExtendedWidth) / size.height;
    return aspectRatio >= 4 / 3;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (_canShowRail(constraints.biggest)) {
        final isExtended = _canExtendRail(constraints.biggest);

        return Row(
          children: [
            Expanded(child: widget.child),
            NavigationRail(
              extended: isExtended,
              labelType: isExtended ? null : NavigationRailLabelType.all,
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              destinations: widget.destinations.map((e) {
                return NavigationRailDestination(
                  icon: e.icon,
                  label: Text(e.label),
                );
              }).toList(),
            ),
          ],
        );
      }

      return Column(
        children: [
          Expanded(child: widget.child),
          NavigationBar(
            selectedIndex: widget.selectedIndex,
            onDestinationSelected: widget.onDestinationSelected,
            destinations: widget.destinations.map((e) {
              return NavigationDestination(
                icon: e.icon,
                label: e.label,
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}
