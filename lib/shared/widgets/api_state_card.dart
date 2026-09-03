import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/api/api_exception.dart';
import '../../core/widgets/soft_card.dart';

class ApiStateCard extends StatelessWidget {
  const ApiStateCard({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.cloud_off_outlined,
  });

  final String title;
  final String? message;
  final IconData icon;

  factory ApiStateCard.error(Object error) {
    final errorText = error.toString();
    final isNotConfigured =
        error is ApiNotConfiguredException ||
        errorText.contains('ApiNotConfiguredException') ||
        errorText.contains('API backend non configuree');
    return ApiStateCard(
      title: isNotConfigured
          ? 'API backend non configuree'
          : 'Connexion au backend impossible',
      message: isNotConfigured
          ? 'Ajoutez HEYN_API_BASE_URL avec l URL du backend Django pour charger les donnees reelles.'
          : 'Verifiez la connexion ou la disponibilite du backend.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.primaryDark),
          const SizedBox(height: AppSpacing.s12),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.title.copyWith(fontSize: 18)),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.s8),
            Text(message!, textAlign: TextAlign.center, style: AppTextStyles.body),
          ],
        ],
      ),
    );
  }
}
