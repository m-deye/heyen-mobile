import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/widgets/product_hero_media.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_session_controller.dart';
import '../application/cart_controller.dart';
import '../application/recurring_cart_controller.dart';

const _deliveryFee = 200.0;
const _freeDeliveryThreshold = 10000.0;

double _deliveryFeeFor(double subtotal) {
  if (subtotal <= 0 || subtotal >= _freeDeliveryThreshold) {
    return 0;
  }
  return _deliveryFee;
}

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lines = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final deliveryFee = _deliveryFeeFor(subtotal);
    final finalTotal = subtotal + deliveryFee;
    final clientType = ref.watch(currentClientTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _CartHeader(
              itemCountLabel: l10n.commonProductCount(lines.length),
              onBack: () => context.canPop() ? context.pop() : context.go('/'),
            ),
            Expanded(
              child: ListView(
                key: const Key('cart-scroll'),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 24),
                children: [
                  if (clientType.isCommercant) const _RecurringCartCard(),
                  if (lines.isEmpty)
                    const _EmptyCart()
                  else ...[
                    for (var i = 0; i < lines.length; i++)
                      _CartLineCard(line: lines[i], index: i),
                    const SizedBox(height: 12),
                    const _CouponRow(),
                    const SizedBox(height: 18),
                    _CartSummaryCard(
                      subtotal: subtotal,
                      deliveryFee: deliveryFee,
                      finalTotal: finalTotal,
                    ),
                  ],
                ],
              ),
            ),
            if (lines.isNotEmpty)
              _StickyCheckoutButton(
                label: clientType.isCommercant
                    ? l10n.cartContinueQuote
                    : l10n.cartPlaceOrder,
                totalLabel: formatOuguiya(finalTotal),
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  context.push('/checkout');
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({required this.itemCountLabel, required this.onBack});

  final String itemCountLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 14),
      child: Row(
        children: [
          _CircleBackButton(onPressed: onBack),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.cartTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HeynTextStyles.sectionTitle.copyWith(
                color: AppColors.darkText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            itemCountLabel,
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox.square(
          dimension: 46,
          child: Center(child: BackButtonIcon()),
        ),
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.subtotal,
    required this.deliveryFee,
    required this.finalTotal,
  });

  final double subtotal;
  final double deliveryFee;
  final double finalTotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _WhiteCard(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 18, 16),
      child: Column(
        children: [
          _SummaryLine(
            label: l10n.cartSubtotal,
            value: formatOuguiya(subtotal),
          ),
          const SizedBox(height: 14),
          _SummaryLine(
            label: l10n.cartDeliveryFee,
            value: formatOuguiya(deliveryFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _SummaryLine(
            label: l10n.commonTotal,
            value: formatOuguiya(finalTotal),
            emphasized: true,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.cartFreeDeliveryHint,
            textAlign: TextAlign.center,
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: HeynTextStyles.subtitle.copyWith(
            color: emphasized ? AppColors.darkText : AppColors.secondaryText,
            fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: HeynTextStyles.bodyMedium.copyWith(
            color: emphasized ? AppColors.primary : AppColors.darkText,
            fontSize: emphasized ? 18 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CartLineCard extends ConsumerWidget {
  const _CartLineCard({required this.line, required this.index});

  final OrderLine line;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(currentClientTypeProvider);
    final unitPrice = line.product.priceFor(type);
    final unitLabel = line.product.details.trim().isNotEmpty
        ? line.product.details
        : line.product.saleMode
              .localizedPriceSuffixFor(type, l10n)
              .replaceFirst('/ ', '');

    return _WhiteCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductHeroMedia(
            product: line.product,
            index: index,
            width: 70,
            height: 74,
            iconSize: 24,
            fit: BoxFit.contain,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    color: AppColors.darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unitLabel · ${formatOuguiya(unitPrice)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeynTextStyles.subtitle.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                _QuantityStepper(
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
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            height: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l10n.commonRemove,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.topRight,
                  constraints: const BoxConstraints.tightFor(
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () => ref
                      .read(cartControllerProvider.notifier)
                      .remove(line.product.id),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.secondaryText,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Text(
                  formatOuguiya(line.lineTotalFor(type)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: HeynTextStyles.priceBold.copyWith(
                    color: AppColors.darkText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(icon: Icons.add, onPressed: onPlus, filled: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '$value',
            style: HeynTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        _StepperButton(icon: Icons.remove, onPressed: onMinus, filled: false),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
    required this.filled,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: filled && enabled ? AppColors.primary : AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: filled && enabled ? AppColors.primary : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox.square(
          dimension: 36,
          child: Icon(
            icon,
            size: 18,
            color: filled && enabled
                ? AppColors.background
                : enabled
                ? AppColors.darkText
                : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        SizedBox(
          width: 128,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.darkButton,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () {},
            child: Text(
              l10n.cartApplyCoupon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.cartCouponHint,
                hintStyle: HeynTextStyles.subtitle.copyWith(
                  color: AppColors.mutedText,
                ),
                prefixIcon: const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StickyCheckoutButton extends StatelessWidget {
  const _StickyCheckoutButton({
    required this.label,
    required this.totalLabel,
    required this.onPressed,
  });

  final String label;
  final String totalLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 14, 20, 16),
        child: SizedBox(
            height: 64,
            child: FilledButton(
              key: const Key('cart-place-order'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: HeynTextStyles.button.copyWith(
                      color: AppColors.background,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: HeynTextStyles.button.copyWith(
                      color: AppColors.background,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: HeynTextStyles.button.copyWith(
                      color: AppColors.background,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _WhiteCard(
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
          Text(l10n.cartEmptyTitle, style: HeynTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Text(
            l10n.cartEmptySubtitle,
            textAlign: TextAlign.center,
            style: HeynTextStyles.subtitle,
          ),
          const SizedBox(height: 18),
          HeynPrimaryButton(
            label: l10n.cartSeeCategories,
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
    final l10n = AppLocalizations.of(context);
    final template = ref.watch(recurringCartControllerProvider);
    final currentLines = ref.watch(cartControllerProvider);

    return _WhiteCard(
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
                  l10n.cartWeeklyTemplateTitle,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.cartWeeklyTemplateSubtitle, style: HeynTextStyles.subtitle),
          const SizedBox(height: 12),
          if (template == null)
            Text(l10n.cartNoTemplate, style: HeynTextStyles.caption)
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
                    '${template.name} · ${l10n.commonArticleCount(template.itemCount)}',
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
                  label: l10n.commonSave,
                  expand: true,
                  onPressed: currentLines.isEmpty
                      ? null
                      : () {
                          ref
                              .read(recurringCartControllerProvider.notifier)
                              .saveFrom(currentLines);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.cartTemplateSaved)),
                          );
                        },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HeynPrimaryButton(
                  label: l10n.commonLoad,
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

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child, this.padding, this.margin});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
    if (margin == null) {
      return card;
    }
    return Padding(padding: margin!, child: card);
  }
}
