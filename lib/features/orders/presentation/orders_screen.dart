import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../theme/heyn_theme.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../../checkout/application/checkout_controllers.dart';
import '../application/order_tracking_controller.dart';
import 'order_status_timeline.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ordersState = ref.watch(ordersProvider);
    final quotes = ref.watch(quotesControllerProvider);
    final clientType = ref.watch(currentClientTypeProvider);

    return DefaultTabController(
      length: 2,
      child: Container(
        color: AppColors.scaffoldBackground,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _OrdersHeader(),
              _OrdersTabs(l10n: l10n),
              Expanded(
                child: ordersState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: ApiStateCard.error(error, l10n),
                  ),
                  data: (orders) {
                    final currentOrders = [
                      for (final order in orders)
                        if (!order.status.isDelivered) order,
                    ];
                    final previousOrders = [
                      for (final order in orders)
                        if (order.status.isDelivered) order,
                    ];

                    return TabBarView(
                      children: [
                        _OrdersList(
                          orders: currentOrders,
                          quotes: clientType.isCommercant ? quotes : const [],
                          emptyTitle: l10n.ordersNoCurrentOrders,
                        ),
                        _OrdersList(
                          orders: previousOrders,
                          quotes: const [],
                          emptyTitle: l10n.ordersNoPreviousOrders,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 18, 20, 8),
      child: Text(
        l10n.navOrders,
        style: HeynTextStyles.displayTitle.copyWith(
          fontSize: 28,
          color: AppColors.darkText,
        ),
      ),
    );
  }
}

class _OrdersTabs extends StatelessWidget {
  const _OrdersTabs({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelPadding: const EdgeInsetsDirectional.only(start: 20, end: 18),
      indicatorPadding: const EdgeInsetsDirectional.only(start: 20, end: 18),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      dividerColor: Colors.transparent,
      labelColor: AppColors.darkText,
      unselectedLabelColor: AppColors.secondaryText,
      labelStyle: AppTextStyles.label.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: AppTextStyles.label.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      tabs: [
        Tab(text: l10n.ordersCurrentTab),
        Tab(text: l10n.ordersPreviousTab),
      ],
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.quotes,
    required this.emptyTitle,
  });

  final List<Order> orders;
  final List<Quote> quotes;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty && quotes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ApiStateCard(title: emptyTitle, icon: Icons.receipt_long_outlined),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      children: [
        for (final quote in quotes) _QuoteCard(quote: quote),
        for (final order in orders) _OrderCard(order: order),
      ],
    );
  }
}

class _QuoteCard extends ConsumerWidget {
  const _QuoteCard({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(currentClientTypeProvider);

    return HeynCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  quote.id,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                ),
              ),
              _StatusPill(
                label: quote.status.localizedLabel(l10n),
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
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            '${quote.paymentMethod.localizedLabel(l10n)} · ${formatOuguiya(quote.totalFor(type))}',
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
                    child: Text(l10n.ordersRejectQuote),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => ref
                        .read(quotesControllerProvider.notifier)
                        .approve(quote.id),
                    child: Text(l10n.ordersApproveQuote),
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
                      l10n.ordersPaymentConfirmed(
                        quote.paymentMethod.localizedLabel(l10n),
                      ),
                    ),
                  ),
                );
              },
              child: Text(l10n.ordersPayAndConfirm),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final itemCount = order.lines.fold<int>(
      0,
      (sum, line) => sum + line.quantity,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(
                label: order.status.localizedLabel(l10n),
                kind: _kindFor(order.status),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  _shortOrderId(order.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.lightTeal,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _orderMeta(l10n, itemCount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                formatOuguiya(order.total),
                style: AppTextStyles.price.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                l10n.cartFinalTotal,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showOrderDetails(context, order),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(l10n.ordersViewDetails),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final cart = ref.read(cartControllerProvider.notifier);
                    for (final line in order.lines) {
                      cart.addProduct(line.product, quantity: line.quantity);
                    }
                    context.go('/cart');
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 19),
                  label: Text(
                    l10n.ordersReorder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.ordersDetailsTitle,
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(order.id, style: AppTextStyles.body),
                const SizedBox(height: 18),
                for (final line in order.lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${line.quantity} x ${line.product.name}',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(l10n.cartFinalTotal, style: AppTextStyles.body),
                    const Spacer(),
                    Text(
                      formatOuguiya(order.total),
                      style: AppTextStyles.price.copyWith(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: OrderStatusTimeline(currentStatus: order.status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _orderMeta(AppLocalizations l10n, int itemCount) {
    final date = order.date;
    final count = l10n.commonProductCount(itemCount);
    if (date == null) {
      return count;
    }
    return '${_formatDateTime(date, l10n.localeName)} · $count';
  }

  String _formatDateTime(DateTime date, String localeName) {
    const frMonths = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    const arMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final months = localeName.startsWith('ar') ? arMonths : frMonths;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year} · $hour:$minute';
  }

  String _shortOrderId(String id) {
    if (id.length <= 8) {
      return id;
    }
    final suffix = id.substring(id.length - 5);
    return 'HN-$suffix';
  }

  _StatusKind _kindFor(OrderStatus status) {
    return switch (status) {
      OrderStatus.livree => _StatusKind.done,
      OrderStatus.enLivraison ||
      OrderStatus.enPreparation => _StatusKind.progress,
      OrderStatus.confirmee => _StatusKind.pending,
    };
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
        style: HeynTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
