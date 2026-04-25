import 'package:flutter/material.dart';

import '../../theme/stitch_tokens.dart';

class StitchBottomNavItem {
  const StitchBottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

/// Stitch bottom navigation:
/// ```
/// h-20 bg-white border-t border-[#edeef0]
/// shadow-[0_-12px_32px_-8px_rgba(5,17,37,0.08)]
/// grid-cols-N equal spacing.
/// Selected: icon+label with `text-primary`, tiny dot underline.
/// ```
class StitchBottomNav extends StatelessWidget {
  const StitchBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<StitchBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: StitchColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: StitchColors.hairline)),
        boxShadow: StitchShadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: StitchLayout.bottomNavHeight,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _StitchBottomNavTile(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StitchBottomNavTile extends StatelessWidget {
  const _StitchBottomNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final StitchBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? StitchColors.primary
        : StitchColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? (item.activeIcon ?? item.icon) : item.icon,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: StitchText.navLabel.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                color: selected ? StitchColors.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
