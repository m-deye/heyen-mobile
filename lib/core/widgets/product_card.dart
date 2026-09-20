import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/formatters/price_formatter.dart';
import '../../shared/localization/display_localizations.dart';
import '../../shared/models/client_type.dart';
import '../../shared/models/product.dart';
import '../../shared/models/sale_mode.dart';
import '../../shared/widgets/product_hero_media.dart';
import '../../theme/heyn_theme.dart';
import '../theme/app_colors.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddPressed,
    this.index = 0,
    this.compact = false,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddPressed;
  final int index;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(currentClientTypeProvider);
    final displayPrice = product.priceFor(type);
    if (compact) {
      return _CompactProductCard(
        product: product,
        onTap: onTap,
        onAddPressed: onAddPressed,
        index: index,
        displayPrice: displayPrice,
        originalPrice: product.hasDiscount
            ? product.price *
                  (type.isCommercant && product.saleMode.soldWholesale
                      ? 1 - ClientType.wholesaleDiscountPercent / 100
                      : 1)
            : null,
      );
    }
    final showWholesale =
        type.isCommercant &&
        (product.saleMode == SaleMode.wholesale ||
            product.saleMode == SaleMode.both);

    return HeynCard(
      padding: EdgeInsets.zero,
      radius: 18,
      borderColor: HeynColors.pastelBorderAt(index),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductHeroMedia(
            product: product,
            index: index,
            width: double.infinity,
            height: 88,
            iconSize: 40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HeynTextStyles.bodyMedium.copyWith(
                      height: 1.1,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatOuguiya(displayPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HeynTextStyles.priceBold.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (showWholesale) ...[
                        Text(
                          l10n.saleModeWholesale,
                          style: HeynTextStyles.caption.copyWith(
                            color: HeynColors.turquoise,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Material(
                        color: Colors.transparent,
                        shape: CircleBorder(
                          side: BorderSide(
                            color: product.canAddToCart
                                ? HeynColors.turquoise
                                : HeynColors.inactiveGrey,
                          ),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: product.canAddToCart ? onAddPressed : null,
                          child: SizedBox.square(
                            dimension: 26,
                            child: Icon(
                              Icons.add,
                              size: 15,
                              color: product.canAddToCart
                                  ? HeynColors.turquoise
                                  : HeynColors.inactiveGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactProductCard extends StatelessWidget {
  const _CompactProductCard({
    required this.product,
    required this.onTap,
    required this.onAddPressed,
    required this.index,
    required this.displayPrice,
    required this.originalPrice,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddPressed;
  final int index;
  final double displayPrice;
  final double? originalPrice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ProductHeroMedia(
                    product: product,
                    index: index,
                    width: double.infinity,
                    height: 104,
                    fit: BoxFit.contain,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13),
                    ),
                  ),
                  if (product.hasDiscount)
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: HeynTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    start: 8,
                    bottom: -12,
                    child: _CompactAddButton(
                      enabled: product.canAddToCart && onAddPressed != null,
                      onTap: onAddPressed,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9, 15, 9, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HeynTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.saleMode.localizedLabel(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HeynTextStyles.caption.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 10.5,
                          height: 1.1,
                        ),
                      ),
                      const Spacer(),
                      if (originalPrice != null) ...[
                        Text(
                          formatOuguiya(originalPrice!),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: HeynTextStyles.caption.copyWith(
                            color: AppColors.mutedText,
                            fontSize: 10.5,
                            decoration: TextDecoration.lineThrough,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        formatOuguiya(displayPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: HeynTextStyles.priceBold.copyWith(
                          color: AppColors.darkText,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
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

class _CompactAddButton extends StatelessWidget {
  const _CompactAddButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.primary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox.square(
          dimension: 26,
          child: Icon(
            Icons.add_rounded,
            size: 19,
            color: enabled ? Colors.white : AppColors.mutedText,
          ),
        ),
      ),
    );
  }
}
