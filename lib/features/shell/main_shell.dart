import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabSpec(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Map'),
    _TabSpec(icon: Icons.article_outlined, activeIcon: Icons.article, label: 'Feed'),
    _TabSpec(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: 'Community'),
    _TabSpec(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  void _onTap(int index) {
    if (index == navigationShell.currentIndex) return;
    HapticFeedback.selectionClick();
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      spec: _tabs[i],
                      selected: i == navigationShell.currentIndex,
                      onTap: () => _onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.spec, required this.selected, required this.onTap});

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navActive : AppColors.navInactive;
    return InkWell(
      onTap: onTap,
      child: Semantics(
        label: spec.label,
        selected: selected,
        button: true,
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? spec.activeIcon : spec.icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                spec.label,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
