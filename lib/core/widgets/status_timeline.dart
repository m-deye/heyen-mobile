import 'package:flutter/material.dart';

import '../../shared/models/order_status.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.currentStatus});

  final OrderStatus currentStatus;

  static const _steps = [
    ('Confirmée', OrderStatus.confirmee, Icons.check_rounded),
    ('En préparation', OrderStatus.enPreparation, Icons.inventory_2_outlined),
    ('En livraison', OrderStatus.enLivraison, Icons.local_shipping_outlined),
    ('Livrée', OrderStatus.livree, Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((step) => step.$2 == currentStatus);

    return Column(
      children: List.generate(_steps.length, (index) {
        final isDone = index <= currentIndex;
        final isLast = index == _steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: isDone ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : _steps[index].$3,
                    size: 14,
                    color: isDone
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: index < currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _steps[index].$1,
                style: AppTextStyles.label.copyWith(
                  color: isDone
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
