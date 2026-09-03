import 'package:flutter/material.dart';

import '../../theme/heyn_theme.dart';
import '../models/payment_method.dart';

class PaymentMethodPicker extends StatelessWidget {
  const PaymentMethodPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final MobilePaymentMethod? selected;
  final ValueChanged<MobilePaymentMethod> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode Paiement',
          style: HeynTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Sélectionnez votre mode de paiement et confirmez.',
          style: HeynTextStyles.subtitle,
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 16) / 3;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final method in MobilePaymentMethod.values)
                  SizedBox(
                    width: width,
                    child: _OperatorCard(
                      method: method,
                      selected: selected == method,
                      onTap: () => onSelected(method),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OperatorCard extends StatelessWidget {
  const _OperatorCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final MobilePaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (method) {
    MobilePaymentMethod.bankily => Icons.check_box_outlined,
    MobilePaymentMethod.masrivi => Icons.shopping_cart_outlined,
    MobilePaymentMethod.sedad => Icons.phone_android_outlined,
    MobilePaymentMethod.cash => Icons.payments_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? HeynColors.navy : HeynColors.creamCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('payment-${method.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 118,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? HeynColors.turquoise : HeynColors.borderGold,
              width: 1.3,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? HeynColors.onNavy
                                : HeynColors.borderGold,
                          ),
                        ),
                        child: Icon(
                          _icon,
                          color: selected
                              ? HeynColors.onNavy
                              : HeynColors.navy,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    method.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: HeynTextStyles.caption.copyWith(
                      color: selected
                          ? HeynColors.onNavy
                          : HeynColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (selected)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: HeynColors.turquoise,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: HeynColors.navy,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
