import 'package:flutter/material.dart';

import '../../theme/heyn_colors.dart';
import '../../theme/heyn_text_styles.dart';
import '../theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.cartCount = 0,
    this.badgeIndex = 2,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;
  final int cartCount;
  final int badgeIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HeynColors.creamCard,
        border: Border(top: BorderSide(color: HeynColors.borderGold)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                _BarItem(
                  item: items[i],
                  selected: currentIndex == i,
                  badgeCount: i == badgeIndex ? cartCount : 0,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.item,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 36,
              decoration: BoxDecoration(
                color: selected ? HeynColors.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: HeynColors.navy.withValues(alpha: 0.28),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Badge(
                  isLabelVisible: badgeCount > 0,
                  label: Text('$badgeCount'),
                  backgroundColor: AppColors.danger,
                  child: Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: 22,
                    color: selected ? HeynColors.onNavy : const Color(0xFF5A6B7A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HeynTextStyles.caption.copyWith(
                color: selected ? HeynColors.navy : const Color(0xFF5A6B7A),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
