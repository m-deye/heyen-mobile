import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/client_type.dart';
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
  var _favoriteVisual = false;

  String get _productLocation =>
      '/catalog/product/${Uri.encodeComponent(widget.productId)}';

  void _addToCart(Product product, {required bool showSnackBar}) {
    final l10n = AppLocalizations.of(context);
    if (!product.canAddToCart) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.productOutOfStock)));
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
            SnackBar(content: Text(l10n.productAddedToCart(product.name))),
          );
        }
      },
    );
  }

  void _orderProduct(Product product) {
    final l10n = AppLocalizations.of(context);
    if (!product.canAddToCart) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.productOutOfStock)));
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
    final l10n = AppLocalizations.of(context);
    final productState = ref.watch(productProvider(widget.productId));
    final clientType = ref.watch(currentClientTypeProvider);

    return productState.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(title: Text(l10n.productDetailTitle)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ApiStateCard.error(error),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: AppColors.scaffoldBackground,
              title: Text(l10n.productGenericTitle),
              leading: IconButton(
                icon: const BackButtonIcon(),
                onPressed: () => context.go('/catalog'),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ApiStateCard(
                  title: l10n.productUnavailable,
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ),
          );
        }

        final categories = ref.watch(categoriesProvider).value ?? const [];
        final allProducts = ref.watch(productsProvider).value ?? const [];
        final categoryLabel = categories
            .where((category) => category.id == product.categoryId)
            .map((category) => localizedCategoryLabel(category, l10n))
            .firstOrNull;
        final unitPrice = product.priceFor(clientType);
        final totalPrice = unitPrice * _quantity;
        final showOriginal = unitPrice < product.price - 0.5;
        final discountPercent = showOriginal
            ? ((1 - unitPrice / product.price) * 100).round()
            : 0;
        final mediaHeight = (MediaQuery.sizeOf(context).height * 0.38).clamp(
          300.0,
          330.0,
        );
        final badges = localizedProductBadges(product, l10n).skip(1).toList();
        final similarProducts = allProducts
            .where(
              (candidate) =>
                  candidate.categoryId == product.categoryId &&
                  candidate.id != product.id &&
                  candidate.apiId != product.apiId,
            )
            .take(6)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackground,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProductHeroHeader(
                          title: l10n.productDetailTitle,
                          product: product,
                          height: mediaHeight,
                          favoriteSelected: _favoriteVisual,
                          onBack: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/catalog');
                            }
                          },
                          onShare: () {
                            Clipboard.setData(
                              ClipboardData(
                                text: '${product.name}\n${product.description}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.productCopied)),
                            );
                          },
                          onFavorite: () {
                            setState(() => _favoriteVisual = !_favoriteVisual);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(19, 8, 19, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ProductInfoSection(
                                product: product,
                                categoryLabel: categoryLabel,
                                badges: badges,
                                discountPercent: discountPercent,
                                showDiscount: showOriginal,
                                unitLabel: product.saleMode.localizedLabel(
                                  l10n,
                                ),
                                stockLabel: _localizedStockLabel(product, l10n),
                                stockTone: _stockTone(product),
                                onCategoryTap: categoryLabel == null
                                    ? null
                                    : () => context.go(
                                        '/catalog?category=${product.categoryId}',
                                      ),
                              ),
                              const SizedBox(height: 14),
                              _PriceBlock(
                                price: formatOuguiya(totalPrice),
                                originalPrice: showOriginal
                                    ? formatOuguiya(product.price * _quantity)
                                    : null,
                                unitPrice: _quantity > 1
                                    ? '${formatOuguiya(unitPrice)} ${product.saleMode.localizedPriceSuffixFor(clientType, l10n)}'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              _DescriptionSection(
                                title: l10n.productDetails,
                                description: product.details.isNotEmpty
                                    ? product.details
                                    : product.description,
                              ),
                              const SizedBox(height: 18),
                              _QuantityCard(
                                label: l10n.productQuantity,
                                quantity: _quantity,
                                onMinus: _quantity > 1
                                    ? () => setState(() => _quantity -= 1)
                                    : null,
                                onPlus:
                                    product.canAddToCart &&
                                        _quantity < product.stock
                                    ? () => setState(() => _quantity += 1)
                                    : null,
                              ),
                              if (similarProducts.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                _SimilarProductsSection(
                                  title: l10n.productSimilarProducts,
                                  products: similarProducts,
                                  clientType: clientType,
                                  onProductTap: (similar) => context.go(
                                    '/catalog/product/${Uri.encodeComponent(similar.id)}',
                                  ),
                                  onAdd: (similar) =>
                                      _addToCart(similar, showSnackBar: true),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _ProductBottomActions(
                  addLabel: product.canAddToCart
                      ? l10n.productAddToCart
                      : l10n.productDetailStockOut,
                  orderLabel: l10n.productOrder,
                  canAdd: product.canAddToCart,
                  onAdd: () => _addToCart(product, showSnackBar: true),
                  onOrder: () => _orderProduct(product),
                  onCategoryTap: categoryLabel == null
                      ? null
                      : () => context.go(
                          '/catalog?category=${product.categoryId}',
                        ),
                  metaLabel: product.saleMode.localizedLabel(l10n),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _localizedStockLabel(Product product, AppLocalizations l10n) {
    if (product.stock <= 0) {
      return l10n.productDetailStockOut;
    }
    if (product.stock <= 10) {
      return l10n.productDetailStockLimited;
    }
    return l10n.productDetailStockAvailable;
  }

  _StockTone _stockTone(Product product) {
    if (product.stock <= 0) {
      return const _StockTone(
        foreground: AppColors.danger,
        background: AppColors.dangerBackground,
        icon: Icons.close_rounded,
      );
    }
    if (product.stock <= 10) {
      return const _StockTone(
        foreground: AppColors.warning,
        background: AppColors.warningBackground,
        icon: Icons.priority_high_rounded,
      );
    }
    return const _StockTone(
      foreground: AppColors.success,
      background: AppColors.successBackground,
      icon: Icons.check_rounded,
    );
  }
}

class _StockTone {
  const _StockTone({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final Color foreground;
  final Color background;
  final IconData icon;
}

class _ProductTopBar extends StatelessWidget {
  const _ProductTopBar({
    required this.title,
    required this.favoriteSelected,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
  });

  final String title;
  final bool favoriteSelected;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Row(
        children: [
          _CircleActionButton(
            onTap: onShare,
            child: const Icon(Icons.share_outlined, size: 20),
          ),
          const SizedBox(width: 10),
          _CircleActionButton(
            onTap: onFavorite,
            child: Icon(
              favoriteSelected ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: favoriteSelected ? AppColors.danger : AppColors.darkText,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: HeynTextStyles.caption.copyWith(
                  color: Colors.transparent,
                  fontSize: 1,
                ),
              ),
            ),
          ),
          _CircleActionButton(onTap: onBack, child: const BackButtonIcon()),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: CircleBorder(
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.35)),
      ),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 42,
          child: IconTheme(
            data: const IconThemeData(color: AppColors.darkText),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ProductHeroHeader extends StatelessWidget {
  const _ProductHeroHeader({
    required this.title,
    required this.product,
    required this.height,
    required this.favoriteSelected,
    required this.onBack,
    required this.onFavorite,
    required this.onShare,
  });

  final String title;
  final Product product;
  final double height;
  final bool favoriteSelected;
  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            foregroundPainter: _SubtleStripePainter(),
            child: ColoredBox(
              color: AppColors.scaffoldBackground,
              child: Center(
                child: ProductHeroMedia(
                  product: product,
                  width: double.infinity,
                  height: height * 0.68,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 18,
            end: 18,
            child: _ProductTopBar(
              title: title,
              favoriteSelected: favoriteSelected,
              onBack: onBack,
              onFavorite: onFavorite,
              onShare: onShare,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtleStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.hatchGreen.withValues(alpha: 0.58)
      ..strokeWidth = 3;
    const spacing = 12.0;
    for (var x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProductInfoSection extends StatelessWidget {
  const _ProductInfoSection({
    required this.product,
    required this.categoryLabel,
    required this.badges,
    required this.discountPercent,
    required this.showDiscount,
    required this.unitLabel,
    required this.stockLabel,
    required this.stockTone,
    required this.onCategoryTap,
  });

  final Product product;
  final String? categoryLabel;
  final List<String> badges;
  final int discountPercent;
  final bool showDiscount;
  final String unitLabel;
  final String stockLabel;
  final _StockTone stockTone;
  final VoidCallback? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                style: HeynTextStyles.displayTitle.copyWith(
                  color: AppColors.darkText,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.08,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              unitLabel,
              style: HeynTextStyles.caption.copyWith(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StockPill(label: stockLabel, tone: stockTone),
            if (showDiscount) _DiscountChip(label: '-$discountPercent%'),
            if (categoryLabel != null)
              _MetaChip(label: categoryLabel!, onTap: onCategoryTap),
            for (final label in badges.take(1)) _MetaChip(label: label),
            if (product.saleMode == SaleMode.both)
              _MetaChip(label: l10n.saleModeWholesale),
          ],
        ),
      ],
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill({required this.label, required this.tone});

  final String label;
  final _StockTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: tone.foreground,
              shape: BoxShape.circle,
            ),
            child: Icon(tone.icon, color: Colors.white, size: 12),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: HeynTextStyles.caption.copyWith(
              color: tone.foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: HeynTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
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

class _DiscountChip extends StatelessWidget {
  const _DiscountChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.darkText,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: HeynTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.price,
    required this.originalPrice,
    required this.unitPrice,
  });

  final String price;
  final String? originalPrice;
  final String? unitPrice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (originalPrice != null) ...[
          Text(
            originalPrice!,
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.mutedText,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 2),
        ],
        _MoneyText(value: price),
        if (unitPrice != null) ...[
          const SizedBox(height: 4),
          Text(
            unitPrice!,
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _MoneyText extends StatelessWidget {
  const _MoneyText({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final amount = value.replaceFirst(' MRU', '');
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: amount,
            style: HeynTextStyles.displayTitle.copyWith(
              color: AppColors.darkText,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(
            text: ' MRU',
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider.withValues(alpha: 0.8)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: HeynTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.start,
            style: HeynTextStyles.subtitle.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  const _QuantityCard({
    required this.label,
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int quantity;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: HeynTextStyles.caption.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          _QuantityButton(
            key: const Key('qty-plus'),
            icon: Icons.add,
            onTap: onPlus,
            filled: true,
          ),
          const SizedBox(width: 16),
          Text(
            '$quantity',
            style: HeynTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 16),
          _QuantityButton(
            key: const Key('qty-minus'),
            icon: Icons.remove,
            onTap: onMinus,
            filled: false,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final foreground = filled ? Colors.white : AppColors.darkText;
    return Material(
      color: filled && enabled ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: SizedBox.square(
          dimension: 34,
          child: Icon(
            icon,
            color: enabled ? foreground : AppColors.mutedText,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _SimilarProductsSection extends StatelessWidget {
  const _SimilarProductsSection({
    required this.title,
    required this.products,
    required this.clientType,
    required this.onProductTap,
    required this.onAdd,
  });

  final String title;
  final List<Product> products;
  final ClientType clientType;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            title,
            style: HeynTextStyles.bodyMedium.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 122,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];
              return _SimilarProductCard(
                product: product,
                price: formatOuguiya(product.priceFor(clientType)),
                onTap: () => onProductTap(product),
                onAdd: product.canAddToCart ? () => onAdd(product) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarProductCard extends StatelessWidget {
  const _SimilarProductCard({
    required this.product,
    required this.price,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final String price;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 156,
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductHeroMedia(
                  product: product,
                  width: 52,
                  height: 82,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: HeynTextStyles.caption.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HeynTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Material(
                        color: onAdd == null
                            ? AppColors.inputFill
                            : AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onAdd,
                          child: SizedBox.square(
                            dimension: 24,
                            child: Icon(
                              Icons.add,
                              color: onAdd == null
                                  ? AppColors.mutedText
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
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
    );
  }
}

class _PrimaryCartButton extends StatelessWidget {
  const _PrimaryCartButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Material(
        color: enabled ? AppColors.primary : AppColors.inputFill,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: enabled ? Colors.white : AppColors.mutedText,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: HeynTextStyles.button.copyWith(
                  color: enabled ? Colors.white : AppColors.mutedText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductBottomActions extends StatelessWidget {
  const _ProductBottomActions({
    required this.addLabel,
    required this.orderLabel,
    required this.canAdd,
    required this.onAdd,
    required this.onOrder,
    required this.onCategoryTap,
    required this.metaLabel,
  });

  final String addLabel;
  final String orderLabel;
  final bool canAdd;
  final VoidCallback onAdd;
  final VoidCallback onOrder;
  final VoidCallback? onCategoryTap;
  final String metaLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(19, 10, 19, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D102D33),
              blurRadius: 18,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onCategoryTap != null)
              SizedBox(
                width: 24,
                height: 1,
                child: GestureDetector(
                  key: const Key('product-category'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onCategoryTap,
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _PrimaryCartButton(
                    label: addLabel,
                    icon: Icons.shopping_cart_outlined,
                    onPressed: canAdd ? onAdd : null,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        metaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: HeynTextStyles.caption.copyWith(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: canAdd ? onOrder : null,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 30),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.darkText,
                          textStyle: HeynTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Text(orderLabel, textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
