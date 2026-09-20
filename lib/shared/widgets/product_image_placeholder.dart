import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProductImagePlaceholder extends StatelessWidget {
  const ProductImagePlaceholder({
    super.key,
    required this.label,
    this.size = 88,
    this.width,
    this.height,
    this.background,
    this.showLabel = true,
  });

  final String label;
  final double size;
  final double? width;
  final double? height;
  final Color? background;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? size,
      width: width ?? size,
      decoration: BoxDecoration(
        color: background ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: AppColors.textMuted, size: 30),
          if (showLabel && label.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}
