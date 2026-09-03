import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum StatusBadgeTone { primary, success, warning, muted }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.primary,
    this.onTap,
  });

  final String label;
  final StatusBadgeTone tone;
  final VoidCallback? onTap;

  factory StatusBadge.fromStatus(String status) {
    final normalized = status.toLowerCase();
    final label = status == 'Stock limite' ? 'Stock limité' : status;
    if (normalized.contains('rupture')) {
      return StatusBadge(label: label, tone: StatusBadgeTone.muted);
    }
    if (normalized.contains('limite') || normalized.contains('promo')) {
      return StatusBadge(label: label, tone: StatusBadgeTone.warning);
    }
    if (normalized.contains('disponible') || normalized.contains('nouveau')) {
      return StatusBadge(label: label, tone: StatusBadgeTone.success);
    }
    return StatusBadge(label: label);
  }

  @override
  Widget build(BuildContext context) {
    final palette = switch (tone) {
      StatusBadgeTone.primary => ChipPalette.lavender,
      StatusBadgeTone.success => ChipPalette.success,
      StatusBadgeTone.warning => ChipPalette.warning,
      StatusBadgeTone.muted => ChipPalette.muted,
    };

    final child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: child,
      ),
    );
  }
}
