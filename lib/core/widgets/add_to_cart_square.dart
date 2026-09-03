import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AddToCartSquare extends StatelessWidget {
  const AddToCartSquare({
    super.key,
    required this.onPressed,
    this.size = 40,
    this.icon = Icons.add,
  });

  final VoidCallback? onPressed;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: size * 0.5, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
