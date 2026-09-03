import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/user.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../shared/widgets/heyn_search_field.dart';
import '../../../shared/widgets/product_card.dart';
import '../../../shared/widgets/product_hero_media.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_navigation.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../auth/application/pending_auth_intent.dart';
import '../../cart/application/cart_controller.dart';
import '../../catalog/data/api_catalog_repository.dart';
import '../../notifications/presentation/notifications_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCategoryId;
  var _bannerIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _searchQuery => _searchController.text.trim();

  void _openCatalog() {
    final params = <String, String>{};
    if (_selectedCategoryId != null) {
      params['category'] = _selectedCategoryId!;
    }
    if (_searchQuery.isNotEmpty) {
      params['search'] = _searchQuery;
    }
    final uri = Uri(
      path: '/catalog',
      queryParameters: params.isEmpty ? null : params,
    );
    context.go(uri.toString());
  }

  static const _banners = [
    (
      title: 'Stockez vos essentiels',
      subtitle: 'Prix pro sur tout le catalogue',
      cta: 'Commander',
    ),
    (
      title: 'Gros et détail en un geste',
      subtitle: 'Prix pro sur tout le catalogue',
      cta: 'Commander',
    ),
    (
      title: 'Livraison à Nouakchott',
      subtitle: 'Prix pro sur tout le catalogue',
      cta: 'Commander',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final user = ref.watch(authSessionControllerProvider);

    return HeynPageBackdrop(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          cacheExtent: 1200,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: _HomeHeader(
                  user: user,
                  searchController: _searchController,
                  notificationCount: ref.watch(orderNotificationsProvider).length,
                  onSearchChanged: (_) => setState(() {}),
                  onSearchSubmitted: (query) {
                    final encoded = Uri.encodeQueryComponent(query.trim());
                    context.go(
                      encoded.isEmpty ? '/catalog' : '/catalog?search=$encoded',
                    );
                  },
                  onAvatarTap: () => requireAuthThen(
                    context: context,
                    ref: ref,
                    redirect: '/profile',
                    onAuthorized: () => context.go('/profile'),
                  ),
                  onNotifyTap: () => openNotifications(context, ref),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: _Greeting(user: user),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _PromoBannerCarousel(
                  banners: _banners,
                  index: _bannerIndex,
                  onPageChanged: (value) => setState(() => _bannerIndex = value),
                  onCta: () => context.go('/catalog'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _CategoriesBlock(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: (id) => setState(() => _selectedCategoryId = id),
                  onSeeAll: _openCatalog,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Populaires cette semaine',
                        style: HeynTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: HeynColors.navy,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _openCatalog,
                      child: Text(
                        'Tout voir',
                        style: HeynTextStyles.caption.copyWith(
                          color: HeynColors.turquoise,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              sliver: SliverToBoxAdapter(
                child: _PopularList(
                  products: products,
                  selectedCategoryId: _selectedCategoryId,
                  searchQuery: _searchQuery,
                  onSeeCategory: () {
                    if (_selectedCategoryId != null) {
                      context.go('/catalog?category=$_selectedCategoryId');
                    } else {
                      context.go('/catalog');
                    }
                  },
                  onOpen: (product) => context.go(
                    '/catalog/product/${Uri.encodeComponent(product.id)}',
                  ),
                  onAdd: (product) {
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
                            content: Text('${product.name} ajouté au panier'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.user,
    required this.searchController,
    required this.notificationCount,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onAvatarTap,
    required this.onNotifyTap,
  });

  final User? user;
  final TextEditingController searchController;
  final int notificationCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotifyTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HeynInitialsAvatar(
          initials: user?.initials ?? 'H',
          onTap: onAvatarTap,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: HeynSearchField(
            key: const Key('home-search'),
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        HeynRoundIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotifyTap,
          showBadge: notificationCount > 0,
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final firstName = user?.firstName ?? 'Heyn';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bonjour, $firstName 🌊✨',
          style: HeynTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: HeynColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        Text('Bon retour parmi nous', style: HeynTextStyles.subtitle),
      ],
    );
  }
}

class _PromoBannerCarousel extends StatelessWidget {
  const _PromoBannerCarousel({
    required this.banners,
    required this.index,
    required this.onPageChanged,
    required this.onCta,
  });

  final List<({String title, String subtitle, String cta})> banners;
  final int index;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 248,
          child: PageView.builder(
            itemCount: banners.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) {
              final banner = banners[i];
              return _PromoBanner(
                title: banner.title,
                subtitle: banner.subtitle,
                cta: banner.cta,
                photo: HeynMedia.bannerPhotoAt(i),
                onCta: onCta,
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: i == index ? 22 : 6,
                decoration: BoxDecoration(
                  color: i == index
                      ? HeynColors.turquoise
                      : HeynColors.silverStart,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.photo,
    required this.onCta,
  });

  final String title;
  final String subtitle;
  final String cta;
  final String photo;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: HeynColors.creamCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HeynColors.borderGold, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ColoredBox(
              color: HeynColors.cream,
              child: HeynPhoto(
                asset: photo,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: HeynColors.borderGold),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                    color: HeynColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: HeynTextStyles.subtitle,
                ),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: HeynColors.buttonGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onCta,
                      customBorder: const StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 6,
                        ),
                        child: Text(
                          cta,
                          style: HeynTextStyles.caption.copyWith(
                            color: HeynColors.onNavy,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }
}

class _CategoriesBlock extends StatelessWidget {
  const _CategoriesBlock({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    required this.onSeeAll,
  });

  final AsyncValue<List<Category>> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;
  final VoidCallback onSeeAll;

  static const _chipFills = [
    Color(0xFFD4EAF3),
    Color(0xFFD6EEF0),
    Color(0xFFD8E6F2),
    Color(0xFFE4F2F4),
  ];

  @override
  Widget build(BuildContext context) {
    return categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ApiStateCard.error(error),
      data: (items) {
        final visible = [
          for (final category in items)
            if (category.id != 'livraison') category,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Catégories',
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: HeynColors.navy,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    'Tout voir',
                    style: HeynTextStyles.caption.copyWith(
                      color: HeynColors.turquoise,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (visible.isEmpty)
              const ApiStateCard(
                title: 'Aucune categorie disponible pour le moment',
                icon: Icons.category_outlined,
              )
            else
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    HeynSelectionChip(
                      label: 'Tout',
                      selected: selectedCategoryId == null,
                      onTap: () => onSelected(null),
                    ),
                    for (var i = 0; i < visible.length; i++) ...[
                      const SizedBox(width: 8),
                      HeynSelectionChip(
                        label: visible[i].label,
                        selected: selectedCategoryId == visible[i].id,
                        fillColor: _chipFills[i % _chipFills.length],
                        borderColor: _chipFills[i % _chipFills.length],
                        onTap: () => onSelected(visible[i].id),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

List<Product> _filterHomeProducts({
  required List<Product> items,
  required String? selectedCategoryId,
  required String searchQuery,
}) {
  final needle = searchQuery.toLowerCase();
  return [
    for (final product in items)
      if ((selectedCategoryId == null ||
              product.categoryId == selectedCategoryId) &&
          (needle.isEmpty ||
              product.name.toLowerCase().contains(needle) ||
              product.description.toLowerCase().contains(needle)))
        product,
  ];
}

class _PopularList extends StatelessWidget {
  const _PopularList({
    required this.products,
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.onOpen,
    required this.onAdd,
    required this.onSeeCategory,
  });

  static const _popularLimit = 6;

  final AsyncValue<List<Product>> products;
  final String? selectedCategoryId;
  final String searchQuery;
  final ValueChanged<Product> onOpen;
  final ValueChanged<Product> onAdd;
  final VoidCallback onSeeCategory;

  @override
  Widget build(BuildContext context) {
    return products.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ApiStateCard.error(error),
      ),
      data: (items) {
        final filtered = _filterHomeProducts(
          items: items,
          selectedCategoryId: selectedCategoryId,
          searchQuery: searchQuery,
        );
        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ApiStateCard(
              title: searchQuery.trim().isEmpty
                  ? 'Aucun produit disponible pour le moment'
                  : 'Aucun résultat pour « $searchQuery »',
              icon: Icons.inventory_2_outlined,
            ),
          );
        }
        final popular = filtered.take(_popularLimit).toList();
        final others = filtered.skip(_popularLimit).toList();
        final hasMore = others.isNotEmpty || selectedCategoryId != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 188,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: popular.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  return _PopularCard(
                    product: popular[i],
                    index: i,
                    onTap: () => onOpen(popular[i]),
                    onAdd: () => onAdd(popular[i]),
                  );
                },
              ),
            ),
            if (hasMore)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onSeeCategory,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: HeynColors.turquoise,
                      side: const BorderSide(color: HeynColors.turquoise),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.grid_view_rounded, size: 16),
                    label: Text(
                      selectedCategoryId != null
                          ? 'Voir tous les produits de cette catégorie'
                          : 'Voir tout le catalogue',
                      style: HeynTextStyles.bodyMedium.copyWith(
                        color: HeynColors.turquoise,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            if (others.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Autres produits',
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: HeynColors.navy,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: others.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 178,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final product = others[i];
                    return ProductCard(
                      index: i,
                      product: product,
                      onTap: () => onOpen(product),
                      onAddPressed: () => onAdd(product),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PopularCard extends ConsumerWidget {
  const _PopularCard({
    required this.product,
    required this.index,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(currentClientTypeProvider);
    final canAdd = product.canAddToCart;
    return SizedBox(
      width: 168,
      child: HeynCard(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
        borderColor: HeynColors.pastelBorderAt(index),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ProductHeroMedia(
              product: product,
              index: index,
              width: double.infinity,
              height: 100,
              iconSize: 36,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 4),
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
                    formatOuguiya(product.priceFor(type)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HeynTextStyles.priceBold.copyWith(fontSize: 14),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: canAdd
                          ? HeynColors.turquoise
                          : HeynColors.inactiveGrey,
                      width: 1.3,
                    ),
                  ),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: canAdd ? onAdd : null,
                    child: SizedBox.square(
                      dimension: 26,
                      child: Icon(
                        Icons.add,
                        size: 15,
                        color: canAdd
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
    );
  }
}
