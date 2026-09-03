import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'heyn_colors.dart';
import 'heyn_text_styles.dart';

class HeynGlassBox extends StatelessWidget {
  const HeynGlassBox({
    super.key,
    required this.child,
    this.radius = 24,
    this.padding,
    this.borderColor,
    this.borderWidth = 1.2,
    this.frosted = false,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double borderWidth;

  /// Si [frosted] est vrai, conserve le flou crème (écrans d'auth uniquement).
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final box = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: frosted ? const Color(0xA3FFFDF7) : HeynColors.creamCard,
        border: Border.all(
          color: borderColor ??
              (frosted ? const Color(0xFFD9BE7E) : HeynColors.borderGold),
          width: borderWidth,
        ),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (!frosted) {
      return ClipRRect(borderRadius: borderRadius, child: box);
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: box,
      ),
    );
  }
}

class GoldGradientHeader extends StatelessWidget {
  const GoldGradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.leading,
    this.trailing,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          children: [
            if (leading != null || trailing != null)
              Row(
                children: [
                  leading ?? const SizedBox(width: 44),
                  const Spacer(),
                  trailing ?? const SizedBox(width: 44),
                ],
              ),
            if (child != null) ...[
              child!,
              const SizedBox(height: 12),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: HeynTextStyles.displayTitle.copyWith(fontSize: 28),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: HeynTextStyles.subtitle,
              ),
            ],
            if (footer != null) ...[const SizedBox(height: 12), footer!],
          ],
        ),
      ),
    );
  }
}

class HeynDarkHeader extends StatelessWidget {
  const HeynDarkHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.bottom,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onBack != null) ...[
                  HeynRoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack!,
                  ),
                  const SizedBox(width: 8),
                ],
                ?leading,
                const Spacer(),
                trailing ?? const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: HeynTextStyles.displayTitle.copyWith(fontSize: 26),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: HeynTextStyles.subtitle),
            ],
            if (bottom != null) ...[const SizedBox(height: 14), bottom!],
          ],
        ),
      ),
    );
  }
}

class HeynPrimaryButton extends StatelessWidget {
  const HeynPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? HeynColors.buttonGradient : null,
          color: enabled ? null : HeynColors.silverStart,
          borderRadius: BorderRadius.circular(28),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: HeynColors.navy.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: HeynColors.onNavy,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: HeynColors.onNavy),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: HeynTextStyles.button.copyWith(
                            color: enabled
                                ? HeynColors.onNavy
                                : HeynColors.textMuted,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeynStepper extends StatelessWidget {
  const HeynStepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: HeynColors.silverGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepIcon(Icons.remove, onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '$value',
              style: HeynTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _stepIcon(Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _stepIcon(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.square(
        dimension: 28,
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? HeynColors.inactiveGrey : HeynColors.textDark,
        ),
      ),
    );
  }
}

class HeynCard extends StatelessWidget {
  const HeynCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HeynColors.creamCard,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? HeynColors.borderGold,
          width: 1.2,
        ),
        boxShadow: const [HeynColors.cardShadow],
      ),
      child: child,
    );

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(onTap: onTap, borderRadius: borderRadius, child: card),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}

class HeynInitialsAvatar extends StatelessWidget {
  const HeynInitialsAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.night = false,
    this.onTap,
  });

  final String initials;
  final double size;
  final bool night;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: night ? null : HeynColors.buttonGradient,
        color: night ? HeynColors.navy : null,
        border: Border.all(color: HeynColors.turquoise, width: 1.2),
      ),
      child: Text(
        initials,
        style: GoogleFonts.inter(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: HeynColors.onNavy,
        ),
      ),
    );
    if (onTap == null) {
      return avatar;
    }
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }
}

class HeynRoundIconButton extends StatelessWidget {
  const HeynRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
    this.onDark = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.92),
      shape: CircleBorder(
        side: BorderSide(
          color: onDark ? HeynColors.turquoise : HeynColors.borderGold,
          width: 1.2,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Badge(
              isLabelVisible: showBadge,
              smallSize: 8,
              backgroundColor: const Color(0xFFE24B4B),
              child: Icon(
                icon,
                color: onDark ? HeynColors.onNavy : HeynColors.navy,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeynSelectionChip extends StatelessWidget {
  const HeynSelectionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.borderColor,
    this.fillColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? HeynColors.navy
          : (fillColor ?? HeynColors.creamCard),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? HeynColors.turquoise
              : (borderColor ?? HeynColors.borderGold),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: HeynTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? HeynColors.onNavy : HeynColors.navy,
            ),
          ),
        ),
      ),
    );
  }
}

class HeynSilverField extends StatelessWidget {
  const HeynSilverField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return HeynGlassBox(
      radius: 28,
      child: SizedBox(
        height: 50,
        child: TextField(
          key: fieldKey,
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: HeynTextStyles.bodyMedium.copyWith(
            color: HeynColors.navy,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: HeynTextStyles.subtitle,
            prefixIcon: Icon(icon, color: HeynColors.turquoise, size: 20),
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class HeynOutlineBadge extends StatelessWidget {
  const HeynOutlineBadge({
    super.key,
    required this.label,
    this.icon = Icons.person_outline,
    this.onDark = true,
  });

  final String label;
  final IconData icon;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? HeynColors.turquoise : HeynColors.navy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: HeynTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
