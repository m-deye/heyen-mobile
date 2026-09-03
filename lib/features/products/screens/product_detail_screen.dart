import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/sale_mode.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../shared/widgets/product_hero_media.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_navigation.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/application/pending_auth_intent.dart';
import '../../cart/application/cart_controller.dart';
import '../../catalog/data/api_catalog_repository.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  var _quantity = 1;

  String get _productLocation =>
      '/catalog/product/${Uri.encodeComponent(widget.productId)}';

  void _addToCart(Product product, {required bool showSnackBar}) {
    if (!product.canAddToCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit en rupture de stock')),
      );
      return;
    }
    requireAuthThen(
      context: context,
      ref: ref,
      redirect: _productLocation,
      addProduct: product,
      quantity: _quantity,
      action: PendingAuthAction.addToCart,
      onAuthorized: () {
        ref
            .read(cartControllerProvider.notifier)
            .addProduct(product, quantity: _quantity);
        if (showSnackBar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${product.name} ajouté au panier')),
          );
        }
      },
    );
  }

  void _orderProduct(Product product) {
    if (!product.canAddToCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit en rupture de stock')),
      );
      return;
    }
    requireAuthThen(
      context: context,
      ref: ref,
      redirect: '/cart/checkout',
      addProduct: product,
      quantity: _quantity,
      action: PendingAuthAction.checkout,
      onAuthorized: () {
        ref
            .read(cartControllerProvider.notifier)
            .addProduct(product, quantity: _quantity);
        context.go('/cart/checkout');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider(widget.productId));
    final clientType = ref.watch(currentClientTypeProvider);

    return productState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Détail produit')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ApiStateCard.error(error),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            backgroundColor: HeynColors.cream,
            appBar: AppBar(
              backgroundColor: HeynColors.cream,
              title: const Text('Produit'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/catalog'),
              ),
            ),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: ApiStateCard(
                  title: 'Ce produit n’est plus dans le catalogue Heyen.',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
          );
        }

        final categories = ref.watch(categoriesProvider).value ?? const [];
        final categoryLabel = categories
            .where((category) => category.id == product.categoryId)
            .map((category) => category.label)
            .firstOrNull;
        final unitPrice = product.priceFor(clientType);
        final totalPrice = unitPrice * _quantity;
        final showOriginal = unitPrice < product.price - 0.5;
        final discountPercent = showOriginal
            ? ((1 - unitPrice / product.price) * 100).round()
            : 0;
        final photoHeight =
            (MediaQuery.sizeOf(context).height * 0.24).clamp(170.0, 230.0);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: HeynPageBackdrop(
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                    child: Row(
                      children: [
                        HeynRoundIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/catalog');
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Détail produit',
                            textAlign: TextAlign.center,
                            style: HeynTextStyles.displayTitle.copyWith(
                              fontSize: 22,
                            ),
                          ),
                        ),
                        HeynRoundIconButton(
                          icon: Icons.ios_share_rounded,
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '${product.name}\n${product.description}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Produit copié dans le presse-papiers'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: photoHeight,
                                    decoration: BoxDecoration(
                                      color: HeynColors.creamCard,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: HeynColors.borderGold,
                                        width: 1.6,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: ProductHeroMedia(
                                        product: product,
                                        width: double.infinity,
                                        height: photoHeight,
                                        fit: BoxFit.cover,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (categoryLabel != null)
                                    _OutlineChip(
                                      key: const Key('product-category'),
                                      label: categoryLabel,
                                      icon: Icons.category_outlined,
                                      onTap: () => context.go(
                                        '/catalog?category=${product.categoryId}',
                                      ),
                                    ),
                                  for (final badge in product.displayBadges)
                                    _OutlineChip(
                                      label: badge,
                                      icon: Icons.inventory_2_outlined,
                                    ),
                                  for (final label
                                      in product.saleMode == SaleMode.both
                                          ? const ["À l'unité", 'En gros']
                                          : [product.saleMode.label])
                                    _OutlineChip(
                                      label: label,
                                      icon: Icons.shopping_bag_outlined,
                                    ),
                                  if (showOriginal)
                                    _OutlineChip(
                                      label: '-$discountPercent%',
                                      filled: true,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                product.name,
                                style: HeynTextStyles.displayTitle.copyWith(
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description,
                                style: HeynTextStyles.subtitle.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                formatOuguiya(totalPrice),
                                style: HeynTextStyles.displayTitle.copyWith(
                                  fontSize: 26,
                                ),
                              ),
                              if (showOriginal)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    formatOuguiya(product.price),
                                    style: HeynTextStyles.subtitle.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              if (_quantity > 1) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${formatOuguiya(unitPrice)} ${product.saleMode.priceSuffixFor(clientType)}',
                                  style: HeynTextStyles.caption,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  14,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: HeynColors.turquoise.withOpacity(0.35),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: HeynColors.turquoise.withOpacity(0.10),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: HeynColors.turquoise.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.info_rounded,
                                            size: 20,
                                            color: HeynColors.turquoise,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Détails du produit',
                                          style: HeynTextStyles.bodyMedium.copyWith(
                                            color: HeynColors.navy,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8F9FA),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        product.details.isNotEmpty
                                            ? product.details
                                            : product.description,
                                        style: HeynTextStyles.subtitle.copyWith(
                                          color: HeynColors.textDark,
                                          fontSize: 14,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          child: Column(
                            children: [
                              HeynGlassBox(
                                radius: 28,
                                child: SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      key: const Key('qty-minus'),
                                      onPressed: _quantity > 1
                                          ? () =>
                                              setState(() => _quantity -= 1)
                                          : null,
                                      icon: const Icon(Icons.remove, size: 18),
                                      color: HeynColors.textDark,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        '$_quantity',
                                        style: HeynTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 18,
                                            ),
                                      ),
                                    ),
                                    IconButton(
                                      key: const Key('qty-plus'),
                                      onPressed:
                                          product.canAddToCart &&
                                              _quantity < product.stock
                                          ? () =>
                                              setState(() => _quantity += 1)
                                          : null,
                                      icon: const Icon(Icons.add, size: 18),
                                      color: HeynColors.textDark,
                                    ),
                                  ],
                                ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              HeynPrimaryButton(
                                label: product.canAddToCart
                                    ? 'Ajouter au panier'
                                    : 'Rupture de stock',
                                icon: Icons.shopping_bag_outlined,
                                onPressed: product.canAddToCart
                                    ? () {
                                        _addToCart(product, showSnackBar: true);
                                      }
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              HeynGlassBox(
                                radius: 28,
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: product.canAddToCart
                                        ? () => _orderProduct(product)
                                        : null,
                                    icon: const Icon(
                                      Icons.shopping_cart_outlined,
                                    ),
                                    label: const Text('Commander'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: HeynColors.navy,
                                      side: BorderSide.none,
                                      backgroundColor: Colors.transparent,
                                      shape: const StadiumBorder(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OutlineChip extends StatelessWidget {
  const _OutlineChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? HeynColors.navy : HeynColors.creamCard,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: filled ? HeynColors.navy : HeynColors.borderGold,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && !filled) ...[
            Icon(icon, size: 14, color: HeynColors.navy),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: HeynTextStyles.caption.copyWith(
              color: filled ? HeynColors.onNavy : HeynColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) {
      return child;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: child,
      ),
    );
  }
}
