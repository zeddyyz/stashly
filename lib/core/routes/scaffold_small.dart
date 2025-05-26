import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:modern_flutter_components/modern_flutter_components_extension.dart';
import 'package:stashly/core/constants/app_context_extension.dart';

class ScaffoldSmall extends StatelessWidget {
  const ScaffoldSmall({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 50, right: 50, bottom: 35),
        decoration: ShapeDecoration(
          color: context.cardColor.withValues(alpha: 0.5),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(
              color: context.colorScheme.primary.withValues(alpha: 0.3),
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        ),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(40),
          child: RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => _goBranch(0),
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedHome01,
                        color: navigationShell.currentIndex == 0
                            ? context.primary
                            : context.primary.withValues(alpha: 0.3),
                        size: 28,
                      ),
                      style: ButtonStyle(
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(
                          context.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _goBranch(1),
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedFolder01,
                        color: navigationShell.currentIndex == 1
                            ? context.primary
                            : context.primary.withValues(alpha: 0.3),
                        size: 28,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _goBranch(2),
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedSettings04,
                        color: navigationShell.currentIndex == 2
                            ? context.primary
                            : context.primary.withValues(alpha: 0.3),
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.bookmark),
      //       label: 'Bookmarks',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //   ],
      //   currentIndex: navigationShell.currentIndex,
      //   onTap: _goBranch,
      // ),
    );
  }
}
