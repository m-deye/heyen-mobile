import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/localization/display_localizations.dart';
import '../../shared/models/order_status.dart';
import '../../theme/heyn_colors.dart';
import '../../theme/heyn_text_styles.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.currentStatus});

  final OrderStatus currentStatus;

  static const _steps = [
    (OrderStatus.confirmee, Icons.check_rounded),
    (OrderStatus.enPreparation, Icons.inventory_2_outlined),
    (OrderStatus.enLivraison, Icons.local_shipping_outlined),
    (OrderStatus.livree, Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = _steps.indexWhere((step) => step.$1 == currentStatus);

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
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? HeynColors.turquoise : Colors.white,
                    border: Border.all(color: HeynColors.turquoise, width: 1.4),
                    boxShadow: isDone
                        ? [
                            BoxShadow(
                              color: HeynColors.turquoise.withValues(
                                alpha: 0.22,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isDone ? Icons.check_rounded : _steps[index].$2,
                    size: 17,
                    color: isDone ? Colors.white : HeynColors.turquoise,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 3,
                    height: 34,
                    decoration: BoxDecoration(
                      color: index < currentIndex
                          ? HeynColors.turquoise
                          : HeynColors.borderGold.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                _steps[index].$1.localizedLabel(l10n),
                style: HeynTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDone ? HeynColors.textDark : HeynColors.textMuted,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
