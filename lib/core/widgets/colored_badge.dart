import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ColoredBadge extends StatelessWidget {
  const ColoredBadge({
    super.key,
    required this.label,
    this.palette = ChipPalette.lavender,
    this.onTap,
  });

  final String label;
  final ChipPalette palette;
  final VoidCallback? onTap;

  factory ColoredBadge.cycling(
    String label,
    int index, {
    Key? key,
    VoidCallback? onTap,
  }) {
    return ColoredBadge(
      key: key,
      label: label,
      palette: AppColors.chipPaletteAt(index + 1),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          fontSize: 12,
          color: palette.foreground,
        ),
      ),
    );

    if (onTap == null) {
      return child;
    }
    return GestureDetector(onTap: onTap, child: child);
  }
}
