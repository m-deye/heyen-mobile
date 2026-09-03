import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/premium_logo.dart';

class HeynLogoHeader extends StatelessWidget {
  const HeynLogoHeader({
    super.key,
    this.subtitle,
    this.showLogo = true,
    this.trailing,
  });

  static const logoPath = 'assets/images/heyn_logo.png';

  final String? subtitle;
  final bool showLogo;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLogo) ...[
          const HeynLogoMark(size: 42),
          const SizedBox(width: AppSpacing.s12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PremiumLogo(fontSize: 28),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: AppSpacing.s8), trailing!],
      ],
    );
  }
}
