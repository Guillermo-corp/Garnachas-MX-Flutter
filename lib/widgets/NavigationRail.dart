import 'package:flutter/material.dart';

class CustomNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isExtended;

  const CustomNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isExtended,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: isExtended,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: isExtended ? null : NavigationRailLabelType.selected,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('inicio'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.restaurant_menu),
          label: Text('Catálogo'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
      ], 

    );
  }
}