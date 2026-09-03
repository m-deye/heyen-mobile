import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color = AppColors.surface,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final VoidCallback? onTap;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }
}
