import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/widgets/product_hero_media.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_session_controller.dart';
import '../application/cart_controller.dart';
import '../application/recurring_cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalProvider);
    final clientType = ref.watch(currentClientTypeProvider);
    return HeynPageBackdrop(
      child: Column(
        children: [
          GoldGradientHeader(
            title: 'Panier',
            subtitle: clientType.isCommercant
                ? 'Tarifs professionnels, panier type hebdomadaire et devis avant commande.'
                : 'Vos lignes de commande avant validation et votre réapprovisionnement.',
          ),
          Expanded(
            child: ListView(
              key: const Key('cart-scroll'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (clientType.isCommercant) const _RecurringCartCard(),
                if (lines.isEmpty)
                  const _EmptyCart()
                else ...[
                  for (var i = 0; i < lines.length; i++)
                    _CartLineCard(line: lines[i], index: i),
                  const SizedBox(height: 10),
                  _TotalCard(total: total),
                  const SizedBox(height: 16),
                  HeynPrimaryButton(
                    label: clientType.isCommercant
                        ? 'Continuer vers le devis'
                        : 'Passer la commande',
                    onPressed: () => context.go('/cart/checkout'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return HeynCard(
      child: Row(
        children: [
          Text('Total', style: HeynTextStyles.bodyMedium),
          const Spacer(),
          Text(
            formatOuguiya(total),
            style: HeynTextStyles.priceBold.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({required this.line, required this.index});

  final OrderLine line;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(currentClientTypeProvider);

    return HeynCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          ProductHeroMedia(
            product: line.product,
            index: index,
            width: 52,
            height: 52,
            iconSize: 24,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeynTextStyles.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  formatOuguiya(line.product.priceFor(type)),
                  style: HeynTextStyles.priceBold,
                ),
              ],
            ),
          ),
          HeynStepper(
            value: line.quantity,
            onMinus: () => ref
                .read(cartControllerProvider.notifier)
                .decrement(line.product.id),
            onPlus: line.quantity < line.product.stock
                ? () => ref
                    .read(cartControllerProvider.notifier)
                    .increment(line.product.id)
                : null,
          ),
          IconButton(
            tooltip: 'Retirer',
            visualDensity: VisualDensity.compact,
            onPressed: () =>
                ref.read(cartControllerProvider.notifier).remove(line.product.id),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: HeynColors.turquoise,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return HeynCard(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: HeynColors.navy,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 34,
              color: HeynColors.onNavy,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: HeynTextStyles.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des produits depuis le catalogue pour préparer une commande.',
            textAlign: TextAlign.center,
            style: HeynTextStyles.subtitle,
          ),
          const SizedBox(height: 18),
          HeynPrimaryButton(
            label: 'Voir les catégories',
            onPressed: () => context.go('/catalog'),
          ),
        ],
      ),
    );
  }
}

class _RecurringCartCard extends ConsumerWidget {
  const _RecurringCartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = ref.watch(recurringCartControllerProvider);
    final currentLines = ref.watch(cartControllerProvider);

    return HeynCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: HeynColors.navy,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: HeynColors.onNavy,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Panier type hebdomadaire',
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sauvegardez les produits rachetés chaque semaine, puis rechargez-les en un tap.',
            style: HeynTextStyles.subtitle,
          ),
          const SizedBox(height: 12),
          if (template == null)
            Text(
              'Aucun panier type enregistré pour le moment.',
              style: HeynTextStyles.caption,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HeynColors.cream,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${template.name} · ${template.itemCount} articles',
                    style: HeynTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final line in template.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${line.quantity} x ${line.product.name}',
                        style: HeynTextStyles.subtitle.copyWith(
                          color: HeynColors.textDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Enregistrer',
                  expand: true,
                  onPressed: currentLines.isEmpty
                      ? null
                      : () {
                          ref
                              .read(recurringCartControllerProvider.notifier)
                              .saveFrom(currentLines);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Panier type enregistré.'),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HeynPrimaryButton(
                  label: 'Charger',
                  onPressed: template == null
                      ? null
                      : () {
                          ref
                              .read(cartControllerProvider.notifier)
                              .replaceLines(template.lines);
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
