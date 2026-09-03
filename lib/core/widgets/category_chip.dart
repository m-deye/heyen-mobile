import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.palette = ChipPalette.lavender,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ChipPalette palette;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? ChipPalette.selected.background : palette.background;
    final fg = selected ? ChipPalette.selected.foreground : palette.foreground;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            child: Text(label, style: AppTextStyles.label.copyWith(color: fg)),
          ),
        ),
      ),
    );
  }
}
