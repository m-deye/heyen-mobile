import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/application/auth_session_controller.dart';
import '../../../shared/models/payment_method.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/services/order_notification_service.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../theme/heyn_theme.dart';
import '../data/api_profile_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionControllerProvider);
    final profileState = ref.watch(userProfileProvider);
    final sessionProfile = user?.toProfile();

    return HeynPageBackdrop(
      child: Column(
        children: [
          if (sessionProfile != null)
            _ProfileHeader(profile: sessionProfile)
          else
            profileState.maybeWhen(
              data: (profile) => profile == null
                  ? const GoldGradientHeader(
                      title: 'Profil',
                      subtitle: 'Compte et préférences',
                    )
                  : _ProfileHeader(profile: profile),
              orElse: () => const GoldGradientHeader(
                title: 'Profil',
                subtitle: 'Compte et préférences',
              ),
            ),
          Expanded(
            child: sessionProfile != null
                ? _ProfileBody(
                    profile: sessionProfile,
                    onLogout: () {
                      context.go('/');
                      ref.read(authSessionControllerProvider.notifier).logout();
                    },
                  )
                : profileState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: ApiStateCard.error(error),
                    ),
                    data: (profile) {
                      if (profile == null) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: ApiStateCard(
                            title: 'Aucun profil disponible pour le moment',
                            icon: Icons.person_outline,
                          ),
                        );
                      }

                      return _ProfileBody(
                        profile: profile,
                        onLogout: () {
                          context.go('/');
                          ref
                              .read(authSessionControllerProvider.notifier)
                              .logout();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return GoldGradientHeader(
      title: profile.fullName,
      footer: HeynOutlineBadge(
        label: profile.type.label,
        icon: profile.type.isCommercant
            ? Icons.storefront_outlined
            : Icons.person_outline,
        onDark: false,
      ),
      child: HeynInitialsAvatar(
        initials: _initialsOf(profile.fullName),
        size: 72,
        night: true,
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
    final paymentLabels = MobilePaymentMethod.values
        .map((method) => method.label)
        .join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const SizedBox(height: 8),
        Center(
          child: Text(profile.type.shortDescription, style: HeynTextStyles.subtitle),
        ),
        const SizedBox(height: 18),
        _ProfileOption(
          icon: Icons.person_outline,
          label: 'Informations personnelles',
          value: profile.phone.isEmpty ? profile.fullName : profile.phone,
          onTap: () => _showProfileDetails(
            context,
            title: 'Informations personnelles',
            lines: [
              profile.fullName,
              if (profile.phone.isNotEmpty) profile.phone,
              if (profile.whatsApp.isNotEmpty) 'WhatsApp : ${profile.whatsApp}',
              profile.type.label,
            ],
          ),
        ),
        if (profile.shopName.isNotEmpty)
          _ProfileOption(
            icon: Icons.storefront_outlined,
            label: 'Boutique',
            value: profile.shopName,
            onTap: () => _showProfileDetails(
              context,
              title: 'Boutique',
              lines: [profile.shopName],
            ),
          ),
        _ProfileOption(
          icon: Icons.location_on_outlined,
          label: 'Adresses',
          value: profile.address.isEmpty ? '—' : profile.address,
          onTap: () => _showProfileDetails(
            context,
            title: 'Adresses',
            lines: [
              profile.address.isEmpty
                  ? 'Aucune adresse enregistrée pour le moment.'
                  : profile.address,
            ],
          ),
        ),
        _ProfileOption(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Moyens de paiement',
          value: paymentLabels,
          onTap: () => _showProfileDetails(
            context,
            title: 'Moyens de paiement',
            lines: [
              for (final method in MobilePaymentMethod.values)
                '${method.label} — ${method.description}',
            ],
          ),
        ),
        _ProfileOption(
          icon: Icons.help_outline,
          label: 'Aide',
          value: 'Support Heyn',
          onTap: () => _openSupport(context, ref),
        ),
        const SizedBox(height: 8),
        _ProfileOption(
          icon: Icons.logout_rounded,
          label: 'Déconnexion',
          value: 'Se déconnecter',
          danger: true,
          onTap: onLogout,
        ),
      ],
    );
  }

  Future<void> _openSupport(BuildContext context, WidgetRef ref) async {
    final opened = await ref.read(orderNotificationServiceProvider).openSupport();
    if (!context.mounted) {
      return;
    }
    if (opened) {
      return;
    }
    await _showProfileDetails(
      context,
      title: 'Aide',
      lines: const [
        'Support Heyn',
        'Le canal WhatsApp n’est pas configuré sur cet appareil. Contactez le service client Heyn pour obtenir de l’aide.',
      ],
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
      return AlertDialog(
        title: Text(title),
        content: Text(lines.where((line) => line.trim().isNotEmpty).join('\n')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      );
    },
  );
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.value,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = danger ? HeynColors.danger : HeynColors.textDark;
    return HeynCard(
      margin: const EdgeInsets.only(bottom: 10),
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: HeynColors.cream,
              shape: BoxShape.circle,
              border: Border.all(
                color: danger ? HeynColors.danger : HeynColors.borderGold,
              ),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: HeynTextStyles.bodyMedium.copyWith(color: color),
                ),
                const SizedBox(height: 2),
                Text(value, style: HeynTextStyles.subtitle),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: danger ? HeynColors.danger : HeynColors.textMuted,
          ),
        ],
      ),
    );
  }
}

String _initialsOf(String fullName) {
  final parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'H';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}
