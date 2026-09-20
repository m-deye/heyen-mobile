import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_locale_controller.dart';
import '../../../features/auth/application/auth_session_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/payment_method.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/order_notification_service.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../theme/heyn_theme.dart';
import '../../notifications/presentation/notifications_sheet.dart';
import '../data/api_profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authSessionControllerProvider);
    final profileState = ref.watch(userProfileProvider);
    final sessionProfile = user?.toProfile();

    return ColoredBox(
      color: HeynColors.pageMint,
      child: SafeArea(
        bottom: false,
        child: sessionProfile != null
            ? _ProfileBody(
                profile: sessionProfile,
                onLogout: () {
                  context.go('/');
                  ref.read(authSessionControllerProvider.notifier).logout();
                },
              )
            : profileState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: ApiStateCard.error(error),
                ),
                data: (profile) {
                  if (profile == null) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: ApiStateCard(
                        title: l10n.profileNoProfile,
                        icon: Icons.person_outline,
                      ),
                    );
                  }

                  return _ProfileBody(
                    profile: profile,
                    onLogout: () {
                      context.go('/');
                      ref.read(authSessionControllerProvider.notifier).logout();
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.onLogout});

  final UserProfile profile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeState = ref.watch(appLocaleControllerProvider);
    final notificationCount = ref.watch(orderNotificationsProvider).length;
    final paymentLabels = MobilePaymentMethod.values
        .map((method) => method.localizedLabel(l10n))
        .join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        Text(
          l10n.profileTitle,
          style: HeynTextStyles.sectionTitle.copyWith(
            fontSize: 26,
            color: HeynColors.textDark,
          ),
        ),
        const SizedBox(height: 24),
        _ProfileSummaryCard(
          profile: profile,
          onEdit: () => _showProfileDetails(
            context,
            title: l10n.profilePersonalInfo,
            lines: [
              profile.fullName,
              if (profile.phone.isNotEmpty) profile.phone,
              if (profile.whatsApp.isNotEmpty)
                l10n.profileWhatsAppLine(profile.whatsApp),
              profile.type.localizedLabel(l10n),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _ProfileOption(
          icon: Icons.location_on_outlined,
          label: l10n.profileRegisteredAddresses,
          value: profile.address.isEmpty ? null : profile.address,
          badgeText: profile.address.isEmpty ? null : '1',
          onTap: () => _showProfileDetails(
            context,
            title: l10n.profileRegisteredAddresses,
            lines: [
              profile.address.isEmpty ? l10n.profileNoAddress : profile.address,
            ],
          ),
        ),
        _ProfileOption(
          icon: Icons.receipt_long_outlined,
          label: l10n.navOrders,
          onTap: () => context.go('/orders'),
        ),
        _ProfileOption(
          icon: Icons.shopping_basket_outlined,
          label: l10n.profileSavedMonthlyCart,
          onTap: () => context.go('/cart'),
        ),
        _ProfileOption(
          key: const Key('profile-language'),
          icon: Icons.translate_rounded,
          label: l10n.languageChangeTitle,
          value: _languageName(l10n, localeState.locale),
          onTap: () => _showLanguagePicker(context, ref),
        ),
        _ProfileOption(
          icon: Icons.notifications_none_rounded,
          label: l10n.notificationsTitle,
          badgeText: notificationCount > 0 ? '$notificationCount' : null,
          onTap: () => openNotifications(context, ref),
        ),
        if (profile.shopName.isNotEmpty)
          _ProfileOption(
            icon: Icons.storefront_outlined,
            label: l10n.profileShop,
            value: profile.shopName,
            onTap: () => _showProfileDetails(
              context,
              title: l10n.profileShop,
              lines: [profile.shopName],
            ),
          ),
        _ProfileOption(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.profilePaymentMethods,
          value: paymentLabels,
          onTap: () => _showProfileDetails(
            context,
            title: l10n.profilePaymentMethods,
            lines: [
              for (final method in MobilePaymentMethod.values)
                '${method.localizedLabel(l10n)} — ${method.localizedDescription(l10n)}',
            ],
          ),
        ),
        _ProfileOption(
          icon: Icons.help_outline_rounded,
          label: l10n.profileHelpAndSupport,
          onTap: () => _openSupport(context, ref),
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton(
            onPressed: onLogout,
            style: TextButton.styleFrom(
              foregroundColor: HeynColors.danger,
              textStyle: HeynTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(l10n.profileLogoutAction),
          ),
        ),
      ],
    );
  }

  Future<void> _openSupport(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final opened = await ref
        .read(orderNotificationServiceProvider)
        .openSupport(message: l10n.whatsAppSupportMessage);
    if (!context.mounted) {
      return;
    }
    if (opened) {
      return;
    }
    await _showProfileDetails(
      context,
      title: l10n.profileHelp,
      lines: [l10n.profileSupport, l10n.profileWhatsAppUnavailable],
    );
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeState = ref.read(appLocaleControllerProvider);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.languageChangeTitle),
          content: RadioGroup<Locale>(
            groupValue: localeState.locale,
            onChanged: (locale) => _changeProfileLanguage(context, ref, locale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<Locale>(
                  key: const Key('profile-language-fr'),
                  value: const Locale('fr'),
                  title: Text(l10n.languageFrenchNative),
                  subtitle: Text(l10n.languageFrench),
                ),
                RadioListTile<Locale>(
                  key: const Key('profile-language-ar'),
                  value: const Locale('ar'),
                  title: Text(l10n.languageArabicNative),
                  subtitle: Text(l10n.languageArabic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeProfileLanguage(
    BuildContext context,
    WidgetRef ref,
    Locale? locale,
  ) async {
    if (locale == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    await ref.read(appLocaleControllerProvider.notifier).setLocale(locale);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.languageUpdated)));
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HeynCard(
      radius: 18,
      padding: const EdgeInsets.all(18),
      borderColor: HeynColors.borderGold.withValues(alpha: 0.55),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              profile.type.isCommercant
                  ? Icons.storefront_outlined
                  : Icons.person_rounded,
              color: HeynColors.turquoise,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
                if (profile.phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(profile.phone, style: HeynTextStyles.subtitle),
                ],
                const SizedBox(height: 6),
                Text(
                  profile.type.localizedLabel(l10n),
                  style: HeynTextStyles.caption.copyWith(
                    color: HeynColors.turquoise,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.type.localizedShortDescription(l10n),
                  style: HeynTextStyles.subtitle.copyWith(
                    color: HeynColors.textMuted,
                  ),
                ),
                if (profile.shopName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HeynTextStyles.subtitle.copyWith(
                      color: HeynColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F8F8),
                  foregroundColor: HeynColors.turquoise,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: HeynTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(
                  l10n.profileEditInformation,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showProfileDetails(
  BuildContext context, {
  required String title,
  required List<String> lines,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(title),
        content: Text(lines.where((line) => line.trim().isNotEmpty).join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      );
    },
  );
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.badgeText,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? badgeText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HeynCard(
      margin: const EdgeInsets.only(bottom: 12),
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderColor: HeynColors.borderGold.withValues(alpha: 0.45),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFFBFB),
              shape: BoxShape.circle,
              border: Border.all(
                color: HeynColors.turquoise.withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, size: 20, color: HeynColors.turquoise),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: HeynTextStyles.bodyMedium.copyWith(
                color: HeynColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (value != null && value!.isNotEmpty) ...[
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: HeynTextStyles.subtitle.copyWith(
                  color: HeynColors.textMuted,
                ),
              ),
            ),
          ],
          if (badgeText != null && badgeText!.isNotEmpty) ...[
            const SizedBox(width: 10),
            _ProfileBadge(text: badgeText!),
          ],
          const SizedBox(width: 8),
          Icon(_chevronFor(context), color: HeynColors.inactiveGrey),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F8),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: HeynTextStyles.caption.copyWith(
          color: HeynColors.turquoise,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

IconData _chevronFor(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl
      ? Icons.chevron_left_rounded
      : Icons.chevron_right_rounded;
}

String _languageName(AppLocalizations l10n, Locale locale) {
  return switch (locale.languageCode) {
    'ar' => l10n.languageArabicNative,
    _ => l10n.languageFrenchNative,
  };
}
