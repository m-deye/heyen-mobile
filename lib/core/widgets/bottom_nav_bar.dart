import 'package:flutter/material.dart';

import '../../theme/heyn_text_styles.dart';
import '../theme/app_colors.dart';

const double _navBarHeight = 58;
const double _itemHorizontalPadding = 3;
const double _itemVerticalPadding = 5;
const double _iconSlotSize = 26;
const double _iconSize = 22;
const double _labelSlotHeight = 13;
const double _iconLabelGap = 3;
const double _labelFontSize = 10;

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
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _navBarHeight,
          child: Row(
            textDirection: Directionality.of(context),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _itemHorizontalPadding,
              vertical: _itemVerticalPadding,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  width: _iconSlotSize,
                  height: _iconSlotSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        selected ? item.selectedIcon : item.icon,
                        size: _iconSize,
                        color: selected
                            ? AppColors.primary
                            : AppColors.mutedText,
                      ),
                      if (badgeCount > 0)
                        PositionedDirectional(
                          top: -5,
                          end: -7,
                          child: _CartBadge(count: badgeCount),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: _iconLabelGap),
                SizedBox(
                  width: double.infinity,
                  height: _labelSlotHeight,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: HeynTextStyles.caption.copyWith(
                          color: selected
                              ? AppColors.primary
                              : AppColors.mutedText,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: _labelFontSize,
                          height: 1,
                        ),
                      ),
                    ),
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

class _CartBadge extends StatelessWidget {
  const _CartBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 14),
      height: 14,
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.cartBadge,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.background, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        maxLines: 1,
        style: HeynTextStyles.caption.copyWith(
          color: AppColors.background,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
