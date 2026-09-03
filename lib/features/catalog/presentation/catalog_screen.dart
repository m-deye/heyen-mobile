import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../shared/widgets/category_media.dart';
import '../../../shared/widgets/heyn_search_field.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_navigation.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/application/pending_auth_intent.dart';
import '../../cart/application/cart_controller.dart';
import '../data/api_catalog_repository.dart';

enum _CatalogFilter { all, available, promo, priceAsc, priceDesc }

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.selectedCategoryId, this.searchQuery});

  final String? selectedCategoryId;
  final String? searchQuery;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  _CatalogFilter _filter = _CatalogFilter.all;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void didUpdateWidget(covariant CatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.searchQuery ?? '';
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != next) {
      _searchController.text = next;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _searchQuery => _searchController.text.trim();

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final productsState = ref.watch(productsProvider);
    final clientType = ref.watch(currentClientTypeProvider);
    final categories = (categoriesState.value ?? const [])
        .where((category) => category.id != 'livraison')
        .toList();
    final allProducts = productsState.value ?? const [];
    final selectedCategory = categories
        .where((category) => category.id == widget.selectedCategoryId)
        .firstOrNull;
    final showingCategory = selectedCategory != null;
    final searching = _searchQuery.isNotEmpty;
    final products = _applyFilter(
      allProducts
          .where((product) {
            final inCategory =
                !showingCategory || product.categoryId == selectedCategory.id;
            if (!inCategory) {
              return false;
            }
            if (!searching) {
              return true;
            }
            final needle = _searchQuery.toLowerCase();
            return product.name.toLowerCase().contains(needle) ||
                product.description.toLowerCase().contains(needle);
          })
          .toList(),
    );
    final isLoading = categoriesState.isLoading || productsState.isLoading;

    return HeynPageBackdrop(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _CatalogHeader(
              clientType: clientType,
              categoryLabel: selectedCategory?.label,
              onBack: showingCategory ? () => context.go('/catalog') : null,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: HeynSearchField(
                key: const Key('catalog-search'),
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          if (!showingCategory && !searching)
            ..._categorySlivers(
              categoriesState: categoriesState,
              productsState: productsState,
              categories: categories,
              products: allProducts,
              isLoading: isLoading,
            )
          else
            ..._productSlivers(
              productsState: productsState,
              products: products,
              isLoading: isLoading,
              searchQuery: _searchQuery,
            ),
        ],
      ),
    );
  }

  List<Widget> _categorySlivers({
    required AsyncValue<List<Category>> categoriesState,
    required AsyncValue<List<Product>> productsState,
    required List<Category> categories,
    required List<Product> products,
    required bool isLoading,
  }) {
    return [
      const SliverToBoxAdapter(child: SizedBox(height: 8)),
      if (isLoading)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        )
      else if (categoriesState.hasError)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ApiStateCard.error(categoriesState.error!),
          ),
        )
      else if (productsState.hasError)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ApiStateCard.error(productsState.error!),
          ),
        )
      else if (categories.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: ApiStateCard(
              title: 'Aucune catégorie disponible pour le moment',
              icon: Icons.category_outlined,
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 200,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              final count = products
                  .where((product) => product.categoryId == category.id)
                  .length;
              return _CategoryCard(
                category: category,
                productCount: count,
                onTap: () => context.go('/catalog?category=${category.id}'),
              );
            }, childCount: categories.length),
          ),
        ),
    ];
  }

  List<Widget> _productSlivers({
    required AsyncValue<List<Product>> productsState,
    required List<Product> products,
    required bool isLoading,
    required String searchQuery,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Livraison',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    products.length <= 1
                        ? '${products.length} produit'
                        : '${products.length} produits',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _openFilter,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Filtrer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      if (isLoading)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        )
      else if (productsState.hasError)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ApiStateCard.error(productsState.error!),
          ),
        )
      else if (products.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: searchQuery.isEmpty
                ? const _EmptyCatalogMessage()
                : ApiStateCard(
                    title: 'Aucun résultat pour « $searchQuery »',
                    icon: Icons.search_off_outlined,
                  ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 178,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return ProductCard(
                index: index,
                product: product,
                onTap: () => context.go(
                  '/catalog/product/${Uri.encodeComponent(product.id)}',
                ),
                onAddPressed: product.canAddToCart
                    ? () {
                        requireAuthThen(
                          context: context,
                          ref: ref,
                          redirect: GoRouterState.of(context).uri.toString(),
                          addProduct: product,
                          action: PendingAuthAction.addToCart,
                          onAuthorized: () {
                            ref
                                .read(cartControllerProvider.notifier)
                                .addProduct(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} ajouté au panier',
                                ),
                              ),
                            );
                          },
                        );
                      }
                    : null,
              );
            }, childCount: products.length),
          ),
        ),
    ];
  }

  List<Product> _applyFilter(List<Product> products) {
    var result = [...products];
    switch (_filter) {
      case _CatalogFilter.available:
        result = result.where((product) => product.canAddToCart).toList();
      case _CatalogFilter.promo:
        result = result
            .where(
              (product) =>
                  product.hasDiscount ||
                  product.status.toLowerCase().contains('promo'),
            )
            .toList();
      case _CatalogFilter.priceAsc:
        result.sort((a, b) => a.price.compareTo(b.price));
      case _CatalogFilter.priceDesc:
        result.sort((a, b) => b.price.compareTo(a.price));
      case _CatalogFilter.all:
        break;
    }
    return result;
  }

  Future<void> _openFilter() async {
    final selected = await showModalBottomSheet<_CatalogFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Filtrer le catalogue')),
              _FilterTile(
                label: 'Tous les produits',
                value: _CatalogFilter.all,
                selected: _filter,
              ),
              _FilterTile(
                label: 'Disponibles',
                value: _CatalogFilter.available,
                selected: _filter,
              ),
              _FilterTile(
                label: 'Promotions',
                value: _CatalogFilter.promo,
                selected: _filter,
              ),
              _FilterTile(
                label: 'Prix croissant',
                value: _CatalogFilter.priceAsc,
                selected: _filter,
              ),
              _FilterTile(
                label: 'Prix décroissant',
                value: _CatalogFilter.priceDesc,
                selected: _filter,
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _filter = selected);
    }
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.value,
    required this.selected,
  });

  final String label;
  final _CatalogFilter value;
  final _CatalogFilter selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected == value
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () => Navigator.of(context).pop(value),
    );
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({
    required this.clientType,
    this.categoryLabel,
    this.onBack,
  });

  final ClientType clientType;
  final String? categoryLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final inCategory = categoryLabel != null;
    final subtitle = inCategory
        ? 'Choisissez un produit de cette catégorie.'
        : clientType.isCommercant
        ? "Prix de gros pour l'approvisionnement de votre commerce."
        : 'Parcourez les catégories et ajoutez vos produits au panier.';

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null)
              IconButton(
                key: const Key('catalog-back'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: HeynColors.textDark,
                ),
              ),
            if (inCategory)
              Text(categoryLabel!, style: HeynTextStyles.displayTitle)
            else
              Text('Catalogue Heyn', style: HeynTextStyles.displayTitle.copyWith(fontSize: 30)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: HeynTextStyles.subtitle.copyWith(
                color: HeynColors.navy.withValues(alpha: 0.82),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.productCount,
    required this.onTap,
  });

  final Category category;
  final int productCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final countLabel = productCount <= 1
        ? '$productCount produit'
        : '$productCount produits';
    final wash = HeynMedia.footerWash(category.id);
    final titleColor = HeynMedia.titleColor(category.id);

    return Material(
      key: Key('category-${category.id}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: HeynColors.borderGold, width: 1.2),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [HeynColors.creamCard, wash.last],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryMedia(
                  category: category,
                  height: 80,
                ),
                const SizedBox(height: 10),
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    height: 1.15,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HeynTextStyles.subtitle.copyWith(
                    height: 1.2,
                    fontSize: 12,
                    color: titleColor.withValues(alpha: 0.78),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: HeynColors.buttonGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    countLabel,
                    style: HeynTextStyles.caption.copyWith(
                      color: HeynColors.onNavy,
                      fontSize: 11,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
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

class _EmptyCatalogMessage extends StatelessWidget {
  const _EmptyCatalogMessage();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(child: Text('Aucun produit disponible pour le moment')),
          ],
        ),
      ),
    );
  }
}

