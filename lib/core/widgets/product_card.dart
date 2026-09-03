import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_session_controller.dart';
import '../../shared/formatters/price_formatter.dart';
import '../../shared/models/product.dart';
import '../../shared/models/sale_mode.dart';
import '../../shared/widgets/product_hero_media.dart';
import '../../theme/heyn_theme.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddPressed,
    this.index = 0,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onAddPressed;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(currentClientTypeProvider);
    final displayPrice = product.priceFor(type);
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
                          style: HeynTextStyles.priceBold.copyWith(fontSize: 14),
                        ),
                      ),
                      if (showWholesale) ...[
                        Text(
                          'En gros',
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
