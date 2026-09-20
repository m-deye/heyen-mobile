import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_logo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/product.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../shared/widgets/category_media.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_navigation.dart';
import '../../auth/application/pending_auth_intent.dart';
import '../../cart/application/cart_controller.dart';
import '../../notifications/presentation/notifications_sheet.dart';
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
    final l10n = AppLocalizations.of(context);
    final categoriesState = ref.watch(categoriesProvider);
    final productsState = ref.watch(productsProvider);
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
      allProducts.where((product) {
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
      }).toList(),
    );
    final isLoading = categoriesState.isLoading || productsState.isLoading;

    return ColoredBox(
      color: AppColors.scaffoldBackground,
      child: CustomScrollView(
        cacheExtent: 1200,
        slivers: [
          SliverToBoxAdapter(
            child: _CatalogHeader(
              title: selectedCategory == null
                  ? l10n.navCategories
                  : localizedCategoryLabel(selectedCategory, l10n),
              searchController: _searchController,
              notificationCount: ref.watch(orderNotificationsProvider).length,
              onBack: showingCategory ? () => context.go('/catalog') : null,
              onSearchChanged: (_) => setState(() {}),
              onNotifyTap: () => openNotifications(context, ref),
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
              categories: categories,
              selectedCategory: selectedCategory,
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
            child: ApiStateCard.error(
              categoriesState.error!,
              AppLocalizations.of(context),
            ),
          ),
        )
      else if (productsState.hasError)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ApiStateCard.error(
              productsState.error!,
              AppLocalizations.of(context),
            ),
          ),
        )
      else if (categories.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: ApiStateCard(
              title: AppLocalizations.of(context).homeNoCategories,
              icon: Icons.category_outlined,
            ),
          ),
        )
      else
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 14),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                AppLocalizations.of(context).catalogShopByCategory,
                style: HeynTextStyles.sectionTitle.copyWith(
                  color: AppColors.darkText,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      if (!isLoading &&
          !categoriesState.hasError &&
          !productsState.hasError &&
          categories.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisExtent: 158,
              crossAxisSpacing: 11,
              mainAxisSpacing: 13,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              return _CategoryCard(
                category: category,
                onTap: () => context.go('/catalog?category=${category.id}'),
              );
            }, childCount: categories.length),
          ),
        ),
    ];
  }

  List<Widget> _productSlivers({
    required AsyncValue<List<Product>> productsState,
    required List<Category> categories,
    required Category? selectedCategory,
    required List<Product> products,
    required bool isLoading,
    required String searchQuery,
  }) {
    final l10n = AppLocalizations.of(context);
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryChips(
                categories: categories,
                selectedCategoryId: selectedCategory?.id,
                onAllTap: () => context.go('/catalog'),
                onCategoryTap: (category) =>
                    context.go('/catalog?category=${category.id}'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _FilterButton(
                    onPressed: _openFilter,
                    label: l10n.commonFilter,
                  ),
                  const Spacer(),
                  Text(
                    l10n.commonProductCount(products.length),
                    style: HeynTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w700,
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
            child: ApiStateCard.error(productsState.error!, l10n),
          ),
        )
      else if (products.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: searchQuery.isEmpty
                ? const _EmptyCatalogMessage()
                : ApiStateCard(
                    title: l10n.commonNoResultsFor(searchQuery),
                    icon: Icons.search_off_outlined,
                  ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(36, 0, 36, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 232,
              crossAxisSpacing: 13,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return ProductCard(
                index: index,
                product: product,
                compact: true,
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
                                  l10n.productAddedToCart(product.name),
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
    final l10n = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<_CatalogFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text(l10n.catalogFilterTitle)),
              _FilterTile(
                label: l10n.catalogFilterAllProducts,
                value: _CatalogFilter.all,
                selected: _filter,
              ),
              _FilterTile(
                label: l10n.catalogFilterAvailable,
                value: _CatalogFilter.available,
                selected: _filter,
              ),
              _FilterTile(
                label: l10n.catalogFilterPromotions,
                value: _CatalogFilter.promo,
                selected: _filter,
              ),
              _FilterTile(
                label: l10n.catalogFilterPriceAsc,
                value: _CatalogFilter.priceAsc,
                selected: _filter,
              ),
              _FilterTile(
                label: l10n.catalogFilterPriceDesc,
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
    required this.title,
    required this.searchController,
    required this.notificationCount,
    required this.onSearchChanged,
    required this.onNotifyTap,
    this.onBack,
  });

  final String title;
  final TextEditingController searchController;
  final int notificationCount;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNotifyTap;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: onBack == null
                          ? const _CatalogLogo()
                          : const SizedBox(width: 52),
                    ),
                    Directionality(
                      textDirection: Directionality.of(context),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: HeynTextStyles.sectionTitle.copyWith(
                          color: AppColors.darkText,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: onBack == null
                          ? _CircleIconButton(
                              icon: Icons.notifications_none_rounded,
                              onTap: onNotifyTap,
                              showBadge: notificationCount > 0,
                            )
                          : _CircleIconButton(
                              key: const Key('catalog-back'),
                              icon: Icons.arrow_back_rounded,
                              onTap: onBack!,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            if (onBack == null)
              SizedBox.shrink(
                child: Opacity(opacity: 0, child: Text(l10n.catalogTitle)),
              ),
            const SizedBox(height: 18),
            _CatalogSearchBar(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      key: Key('category-${category.id}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(7, 8, 7, 7),
            child: Column(
              children: [
                Expanded(child: CategoryMedia(category: category, height: 108)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 34,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.lightTeal,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          localizedCategoryLabel(category, l10n),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: HeynTextStyles.caption.copyWith(
                            color: AppColors.primaryDark,
                            fontSize: 11.5,
                            height: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
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

class _CatalogLogo extends StatelessWidget {
  const _CatalogLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      HeynLogoMark.logoPath,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.shopping_cart_outlined,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chipBackground,
      shape: const CircleBorder(),
      elevation: 1.5,
      shadowColor: AppColors.shadow,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 52,
          child: Center(
            child: Badge(
              isLabelVisible: showBadge,
              smallSize: 8,
              backgroundColor: AppColors.cartBadge,
              child: Icon(icon, color: AppColors.darkText, size: 23),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogSearchBar extends StatelessWidget {
  const _CatalogSearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: TextField(
        key: const Key('catalog-search'),
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        textAlign: TextAlign.start,
        style: HeynTextStyles.bodyMedium.copyWith(
          color: AppColors.darkText,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: l10n.commonSearchProduct,
          hintStyle: HeynTextStyles.subtitle.copyWith(
            color: AppColors.secondaryText.withValues(alpha: 0.78),
            fontSize: 13,
          ),
          suffixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.secondaryText,
            size: 25,
          ),
          prefixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.commonClear,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedCategoryId,
    required this.onAllTap,
    required this.onCategoryTap,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final VoidCallback onAllTap;
  final ValueChanged<Category> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: Directionality.of(context) == TextDirection.rtl,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryChip(
              label: l10n.commonAll,
              selected: selectedCategoryId == null,
              onTap: onAllTap,
            );
          }
          final category = categories[index - 1];
          return _CategoryChip(
            label: localizedCategoryLabel(category, l10n),
            selected: selectedCategoryId == category.id,
            onTap: () => onCategoryTap(category),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: categories.length + 1,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.chipBackground,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: HeynTextStyles.caption.copyWith(
              color: selected ? Colors.white : AppColors.darkText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: HeynTextStyles.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.tune_rounded,
                color: AppColors.darkText,
                size: 16,
              ),
            ],
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
    final l10n = AppLocalizations.of(context);
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.homeNoProducts)),
          ],
        ),
      ),
    );
  }
}
