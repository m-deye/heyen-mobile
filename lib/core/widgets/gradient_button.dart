import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.goldBorder = false,
    this.solid = false,
    this.borderRadius = AppRadius.pill,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final bool goldBorder;
  final bool solid;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(borderRadius);

    return Container(
      height: 52,
      width: expand ? double.infinity : null,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: enabled ? AppColors.buttonGradient : null,
        color: enabled ? null : AppColors.surfaceMuted,
        boxShadow: enabled ? AppColors.primaryButtonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: Center(
            child: isLoading
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: Colors.white),
                        const SizedBox(width: AppSpacing.s8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
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
