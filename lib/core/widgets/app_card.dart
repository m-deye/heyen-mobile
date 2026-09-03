import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(onTap: onTap, borderRadius: radius, child: card),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}
