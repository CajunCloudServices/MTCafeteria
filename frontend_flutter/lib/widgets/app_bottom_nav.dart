import 'package:flutter/material.dart';

import '../theme/stitch_tokens.dart';

/// Stitch-styled persistent bottom navigation.
///
/// Mirrors:
/// ```
/// bg-[#f8f9fb] border-t border-[#c5c6cd]/15
/// shadow-[0_-12px_32px_-8px_rgba(5,17,37,0.08)] px-4 py-3 pb-safe
/// Selected tile: bg-primary text-on-primary rounded-lg
/// ```
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(
      icon: Icons.home_rounded,
      outlineIcon: Icons.home_outlined,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.dashboard_rounded,
      outlineIcon: Icons.dashboard_outlined,
      label: 'Dashboard',
    ),
    _NavItem(
      icon: Icons.person_rounded,
      outlineIcon: Icons.person_outline_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StitchColors.surface,
        border: Border(
          top: BorderSide(
            color: StitchColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        boxShadow: StitchShadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                _BottomNavTile(
                  item: _items[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
  });

  final IconData icon;
  final IconData outlineIcon;
  final String label;
}

class _BottomNavTile extends StatelessWidget {
  const _BottomNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? StitchColors.onPrimary : StitchColors.onSurfaceVariant;
    final bg = selected ? StitchColors.primary : Colors.transparent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(StitchRadii.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(StitchRadii.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? item.icon : item.outlineIcon,
                color: fg,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label.toUpperCase(),
                style: StitchText.navLabel.copyWith(color: fg),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
