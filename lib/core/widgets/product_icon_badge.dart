import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ProductIconBadge extends StatelessWidget {
  const ProductIconBadge({
    super.key,
    required this.categoryId,
    this.index,
    this.size = 56,
    this.iconSize,
  });

  final String categoryId;
  final int? index;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final tone = ProductIconTone.forItem(categoryId: categoryId, index: index);
    final glyph = ProductIconTone.iconFor(categoryId);
    final resolvedIconSize = iconSize ?? size * 0.46;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(glyph, size: resolvedIconSize, color: tone.icon),
    );
  }
}
