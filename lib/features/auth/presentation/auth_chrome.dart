import 'package:flutter/material.dart';

import '../../../core/widgets/premium_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/client_type.dart';
import '../../../theme/heyn_theme.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HeynPageBackdrop(child: child);
  }
}

class AuthLogoBadge extends StatelessWidget {
  const AuthLogoBadge({super.key, this.size = 108});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: HeynColors.goldGradient,
        boxShadow: [
          BoxShadow(
            color: HeynColors.goldDark.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: HeynColors.nightPurple,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.18),
          child: Image.asset(
            HeynLogoMark.logoPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.shopping_bag_outlined,
              size: size * 0.38,
              color: HeynColors.goldLight,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthGlassPanel extends StatelessWidget {
  const AuthGlassPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class AuthGlassField extends StatelessWidget {
  const AuthGlassField({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HeynGlassBox(radius: 28, frosted: true, child: child);
  }
}

class AuthClientTypeToggle extends StatelessWidget {
  const AuthClientTypeToggle({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ClientType selected;
  final ValueChanged<ClientType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _TypeChip(
            label: ClientType.particulier.localizedLabel(l10n),
            icon: Icons.person_outline,
            selected: selected == ClientType.particulier,
            onTap: () => onSelected(ClientType.particulier),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TypeChip(
            label: ClientType.commercant.localizedLabel(l10n),
            icon: Icons.storefront_outlined,
            selected: selected == ClientType.commercant,
            onTap: () => onSelected(ClientType.commercant),
          ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? HeynColors.nightPurple : const Color(0x99FFFDF7),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? HeynColors.goldLight : HeynColors.borderGold,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? HeynColors.goldLight : HeynColors.nightPurple,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: HeynTextStyles.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? HeynColors.goldLight
                      : HeynColors.nightPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HeynPrimaryButton(
      label: label,
      isLoading: isLoading,
      onPressed: onPressed,
    );
  }
}

class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HeynGlassBox(
      radius: 28,
      frosted: true,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: HeynColors.nightPurple,
            side: BorderSide.none,
            backgroundColor: Colors.transparent,
            shape: const StadiumBorder(),
            textStyle: HeynTextStyles.button,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: HeynTextStyles.subtitle,
    filled: false,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  );
}
