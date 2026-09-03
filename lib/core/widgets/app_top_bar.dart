import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'premium_logo.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.backKey,
    this.leading,
    this.trailing,
    this.bottom,
    this.light = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Key? backKey;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final hasBack = onBack != null;
    final onColor = AppColors.textPrimary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        hasBack ? AppSpacing.s8 : AppSpacing.s20,
        topInset + AppSpacing.s8,
        AppSpacing.s20,
        AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: light ? Colors.white : null,
        gradient: light ? null : AppColors.headerGradient,
        borderRadius: light
            ? BorderRadius.zero
            : const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.sheet),
                bottomRight: Radius.circular(AppRadius.sheet),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasBack)
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      key: backKey,
                      onPressed: onBack,
                      color: onColor,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                  ),
                  if (trailing != null)
                    Align(alignment: Alignment.centerRight, child: trailing),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.s12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.title.copyWith(
                          color: onColor,
                          fontSize: 26,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.subtitle.copyWith(color: onColor),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          if (hasBack)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      color: onColor,
                      fontSize: 26,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      subtitle!,
                      style: AppTextStyles.subtitle.copyWith(color: onColor),
                    ),
                  ],
                ],
              ),
            ),
          if (bottom != null) ...[
            const SizedBox(height: AppSpacing.s16),
            bottom!,
          ],
        ],
      ),
    );
  }
}

class HeynBrandHeader extends StatelessWidget {
  const HeynBrandHeader({super.key, this.subtitle});

  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return AppTopBar(
      light: true,
      title: 'Heyn',
      subtitle: subtitle,
      leading: const HeynLogoMark(size: 44),
    );
  }
}
