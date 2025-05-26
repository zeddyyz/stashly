import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldLarge extends StatelessWidget {
  const ScaffoldLarge({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
