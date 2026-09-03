import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../models/client_type.dart';

class ClientTypeBadge extends StatelessWidget {
  const ClientTypeBadge({super.key, required this.type, this.onDark = false});

  final ClientType type;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final palette = onDark ? ChipPalette.bannerChip : ChipPalette.muted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type.isCommercant
                ? Icons.storefront_outlined
                : Icons.person_outline,
            size: 16,
            color: palette.foreground,
          ),
          const SizedBox(width: 6),
          Text(
            type.label,
            style: AppTextStyles.label.copyWith(color: palette.foreground),
          ),
        ],
      ),
    );
  }
}
