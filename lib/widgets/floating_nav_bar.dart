// lib/widgets/floating_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:physics_ease_release/theme/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final ThemeMode themeMode;
  final List<NavBarItem> items;

  const FloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.themeMode,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shadowColor = AppTheme.shadowForTheme(themeMode, alpha: 0.8);
    final int totalFlex = 11 + (items.length - 1) * 4;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 35,
            offset: const Offset(0, 50),
            spreadRadius: 40,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double unitWidth = constraints.maxWidth / totalFlex;

          double leftForIndex(int index) {
            if (index <= 0) return 0;
            return (4 * index) * unitWidth;
          }

          double widthForIndex(int index) {
            final int flex = selectedIndex == index ? 11 : 4;
            return flex * unitWidth;
          }

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOutCubic,
                left: leftForIndex(selectedIndex) + 4,
                width: widthForIndex(selectedIndex) - 8,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final navItem = items[index];
                  final bool isSelected = selectedIndex == index;
                  final Color foregroundColor = isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant;
                  final int flex = isSelected ? 11 : 4;

                  return Flexible(
                    flex: flex,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4, left: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Material(
                        color: AppTheme.transparent,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          splashColor: AppTheme.transparent,
                          highlightColor: AppTheme.transparent,
                          focusColor: AppTheme.transparent,
                          hoverColor: AppTheme.transparent,
                          onTap: () => onItemTapped(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  navItem.icon,
                                  size: 24,
                                  color: foregroundColor,
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      navItem.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                      style: TextStyle(
                                        color: foregroundColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NavBarItem {
  final IconData icon;
  final String label;

  const NavBarItem({required this.icon, required this.label});
}
