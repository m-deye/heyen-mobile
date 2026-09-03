import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../theme/heyn_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../checkout/application/checkout_controllers.dart';
import '../application/order_tracking_controller.dart';
import 'order_status_timeline.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);
    final quotes = ref.watch(quotesControllerProvider);
    final clientType = ref.watch(currentClientTypeProvider);

    return HeynPageBackdrop(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _OrdersHeader(clientType: clientType)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (clientType.isCommercant) ...[
                  Text(
                    'Devis',
                    style: HeynTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 12),
                  if (quotes.isEmpty)
                    const _EmptyQuotesCard()
                  else
                    for (final quote in quotes) _QuoteCard(quote: quote),
                  const SizedBox(height: 24),
                ],
                Text('Historique', style: HeynTextStyles.sectionTitle),
                const SizedBox(height: 12),
                ordersState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => ApiStateCard.error(error),
                  data: (orders) {
                    if (orders.isEmpty && quotes.isEmpty) {
                      return const ApiStateCard(
                        title: 'Aucune commande pour le moment',
                        icon: Icons.receipt_long_outlined,
                      );
                    }

                    return Column(
                      children: [
                        for (final order in orders) _OrderCard(order: order),
                      ],
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.clientType});

  final ClientType clientType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              clientType.isCommercant
                  ? 'Devis et commandes'
                  : 'Historique des commandes',
              style: HeynTextStyles.displayTitle,
            ),
            const SizedBox(height: 6),
            Text(
              clientType.isCommercant
                  ? 'Les devis gros attendent la validation admin, puis le paiement mobile.'
                  : 'Commandes livrées, en cours, et confirmations WhatsApp.',
              style: HeynTextStyles.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQuotesCard extends StatelessWidget {
  const _EmptyQuotesCard();

  @override
  Widget build(BuildContext context) {
    return HeynCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
      child: Column(
        children: [
          Icon(Icons.crop_din, size: 34, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'Aucun devis pour le moment',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends ConsumerWidget {
  const _QuoteCard({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(currentClientTypeProvider);

    return HeynCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(quote.id, style: AppTextStyles.label.copyWith(fontSize: 15)),
              ),
              _StatusPill(
                label: quote.status.label,
                kind: quote.status == QuoteStatus.approved
                    ? _StatusKind.done
                    : quote.status == QuoteStatus.rejected
                    ? _StatusKind.pending
                    : _StatusKind.progress,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(quote.shopName, style: AppTextStyles.body),
          const SizedBox(height: 10),
          for (final line in quote.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '${line.quantity} x ${line.product.name}',
                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '${quote.paymentMethod.label} · ${formatOuguiya(quote.totalFor(type))}',
            style: AppTextStyles.price.copyWith(fontSize: 16),
          ),
          if (quote.status == QuoteStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref
                        .read(quotesControllerProvider.notifier)
                        .reject(quote.id),
                    child: const Text('Refuser'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => ref
                        .read(quotesControllerProvider.notifier)
                        .approve(quote.id),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ],
          if (quote.status == QuoteStatus.approved) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                ref
                    .read(localOrdersControllerProvider.notifier)
                    .addFromQuote(quote);
                ref.read(quotesControllerProvider.notifier).remove(quote.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Paiement ${quote.paymentMethod.label} confirmé. WhatsApp notifié.',
                    ),
                  ),
                );
              },
              child: const Text('Payer et confirmer'),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final itemCount = order.lines.fold<int>(0, (sum, line) => sum + line.quantity);
    return HeynCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (order.date != null)
                Text(_formatDate(order.date!), style: HeynTextStyles.subtitle),
            ],
          ),
          const SizedBox(height: 10),
          _StatusPill(label: order.status.label, kind: _kindFor(order.status)),
          const SizedBox(height: 8),
          Text(
            itemCount <= 1 ? '$itemCount article' : '$itemCount articles',
            style: HeynTextStyles.subtitle,
          ),
          const SizedBox(height: 8),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${line.quantity} x ${line.product.name}',
                style: HeynTextStyles.subtitle,
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatOuguiya(order.total),
              style: HeynTextStyles.priceBold.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
            decoration: BoxDecoration(
              color: HeynColors.cream,
              borderRadius: BorderRadius.circular(16),
            ),
            child: OrderStatusTimeline(currentStatus: order.status),
          ),
        ],
      ),
    );
  }

  _StatusKind _kindFor(OrderStatus status) {
    return switch (status) {
      OrderStatus.livree => _StatusKind.done,
      OrderStatus.enLivraison || OrderStatus.enPreparation => _StatusKind.progress,
      OrderStatus.confirmee => _StatusKind.pending,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

enum _StatusKind { pending, progress, done }

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.kind});

  final String label;
  final _StatusKind kind;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (kind) {
      _StatusKind.pending => (HeynColors.silverStart, HeynColors.textDark),
      _StatusKind.progress => (HeynColors.turquoise, HeynColors.onNavy),
      _StatusKind.done => (HeynColors.navy, Colors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: HeynTextStyles.caption.copyWith(color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
