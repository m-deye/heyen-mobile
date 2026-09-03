import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Palet capsule 3D : dégradé violet, reflet blanc en haut, ombre en bas.
class GlossyPalet extends StatelessWidget {
  const GlossyPalet({
    super.key,
    required this.child,
    this.height = 52,
    this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final double height;
  final VoidCallback? onTap;
  final bool enabled;

  static const _top = Color(0xFF8E44AD);
  static const _mid = Color(0xFF4A2B85);
  static const _bottom = Color(0xFF2A1048);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.pill);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: enabled
              ? const [_top, _mid, _bottom]
              : [AppColors.metal, AppColors.metal],
          stops: enabled ? const [0.0, 0.48, 1.0] : null,
        ),
        border: Border.all(
          color: const Color(0xFFC5A070).withValues(alpha: 0.45),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: const Color(0xFF4A2B85).withValues(alpha: 0.55),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x73FFFFFF),
                          Color(0x26FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: [0.0, 0.38, 0.55],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 3,
                  left: 18,
                  right: 18,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00FFFFFF),
                            Color(0xD9FFFFFF),
                            Color(0x00FFFFFF),
                          ],
                        ),
                      ),
                      child: SizedBox(height: 2.4),
                    ),
                  ),
                ),
                Center(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlossyPaletLabel extends StatelessWidget {
  const GlossyPaletLabel({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
        ],
        Text(label, style: AppTextStyles.button),
      ],
    );
  }
}
