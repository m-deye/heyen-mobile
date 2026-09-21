import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/formatters/price_formatter.dart';
import '../../../shared/localization/display_localizations.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/product.dart';
import '../../../shared/models/sale_mode.dart';
import '../../../shared/widgets/api_state_card.dart';
import '../../../shared/widgets/product_hero_media.dart';
import '../../../core/widgets/premium_logo.dart';
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
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (mounted) {
      setState(() {});
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final searching = _searchQuery.isNotEmpty;

    return HeynBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          cacheExtent: 1200,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: _HomeHeader(
                  searchController: _searchController,
                  notificationCount: ref
                      .watch(orderNotificationsProvider)
                      .length,
                  onSearchChanged: (_) => setState(() {}),
                  onSearchSubmitted: (_) {},
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
            if (!searching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _PromoBannerCarousel(
                  banners: [
                    (
                      title: l10n.homeBannerEssentialsTitle,
                      subtitle: l10n.homeBannerSubtitle,
                      cta: l10n.homeBannerCta,
                    ),
                    (
                      title: l10n.homeBannerWholesaleTitle,
                      subtitle: l10n.homeBannerSubtitle,
                      cta: l10n.homeBannerCta,
                    ),
                    (
                      title: l10n.homeBannerDeliveryTitle,
                      subtitle: l10n.homeBannerSubtitle,
                      cta: l10n.homeBannerCta,
                    ),
                  ],
                  index: _bannerIndex,
                  onPageChanged: (value) =>
                      setState(() => _bannerIndex = value),
                  onCta: () => context.go('/catalog'),
                ),
              ),
            ),
            if (!searching)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _CategoriesBlock(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onSelected: (id) {
                    if (id == null) {
                      setState(() => _selectedCategoryId = null);
                      return;
                    }
                    context.go(
                      '/catalog?category=${Uri.encodeQueryComponent(id)}',
                    );
                  },
                  onSeeAll: _openCatalog,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        searching
                            ? l10n.homeSearchResults
                            : l10n.homePopularThisWeek,
                        style: HeynTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.darkText,
                        ),
                      ),
                    ),
                    if (!searching)
                    TextButton(
                      onPressed: _openCatalog,
                      child: Text(
                        l10n.commonSeeAll,
                        style: HeynTextStyles.caption.copyWith(
                          color: AppColors.darkText,
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
                            content: Text(
                              l10n.productAddedToCart(product.name),
                            ),
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

class HeynBackground extends StatelessWidget {
  const HeynBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.scaffoldBackground),
        Positioned(
          top: -78,
          right: -62,
          child: _SoftBlob(
            width: 210,
            height: 210,
            color: AppColors.lightTeal.withValues(alpha: 0.84),
          ),
        ),
        Positioned(
          top: 210,
          left: -96,
          child: _SoftBlob(
            width: 230,
            height: 150,
            color: AppColors.hatchGreen.withValues(alpha: 0.56),
          ),
        ),
        Positioned(
          bottom: 70,
          right: -86,
          child: _SoftBlob(
            width: 260,
            height: 180,
            color: HeynColors.turquoise.withValues(alpha: 0.10),
          ),
        ),
        const Positioned.fill(child: CustomPaint(painter: _HomeWavesPainter())),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _SoftBlob extends StatelessWidget {
  const _SoftBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(width),
        ),
      ),
    );
  }
}

class _HomeWavesPainter extends CustomPainter {
  const _HomeWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 18
      ..color = HeynColors.turquoise.withValues(alpha: 0.055);

    for (var i = 0; i < 6; i++) {
      final y = 78.0 + i * 126.0;
      final path = Path()..moveTo(-24, y);
      path.cubicTo(
        size.width * 0.22,
        y - 44,
        size.width * 0.72,
        y + 48,
        size.width + 24,
        y - 8,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.searchController,
    required this.notificationCount,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onAvatarTap,
    required this.onNotifyTap,
  });

  final TextEditingController searchController;
  final int notificationCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotifyTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            height: 52,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _HomeBrandMark(),
                const Spacer(),
                _HomeCircleButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotifyTap,
                  showBadge: notificationCount > 0,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              _HomeFilterButton(onTap: onAvatarTap),
              const SizedBox(width: 12),
              Expanded(
                child: _HomeSearchBar(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchSubmitted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeBrandMark extends StatelessWidget {
  const _HomeBrandMark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      HeynLogoMark.logoPath,
      width: 50,
      height: 50,
      fit: BoxFit.contain,
    );
  }
}

class _HomeCircleButton extends StatelessWidget {
  const _HomeCircleButton({
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

class _HomeFilterButton extends StatelessWidget {
  const _HomeFilterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      elevation: 1.5,
      shadowColor: AppColors.shadow,
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: const SizedBox.square(
          dimension: 54,
          child: Icon(Icons.tune_rounded, color: AppColors.darkText, size: 25),
        ),
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Directionality(
        textDirection: Directionality.of(context),
        child: TextField(
          key: const Key('home-search'),
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textAlign: TextAlign.start,
          style: HeynTextStyles.bodyMedium.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: l10n.commonSearchProduct,
            hintStyle: HeynTextStyles.subtitle.copyWith(
              color: AppColors.secondaryText.withValues(alpha: 0.82),
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.secondaryText,
              size: 24,
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
      ),
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
    return Stack(
      children: [
        SizedBox(
          height: 168,
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
        Positioned(
          left: 0,
          right: 0,
          bottom: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: i == index ? 18 : 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
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
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, constraints) {
        final photoWidth = (constraints.maxWidth * 0.48)
            .clamp(176.0, 214.0)
            .toDouble();
        return InkWell(
          onTap: onCta,
          borderRadius: BorderRadius.circular(19),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(19),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photo == HeynMedia.homeBanner)
                  HeynPhoto(
                    asset: photo,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                else ...[
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: isRtl
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          end: isRtl
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          colors: const [Color(0xFFFFFFFF), Color(0xFFEAF7F7)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -8,
                    top: 0,
                    bottom: 0,
                    width: photoWidth,
                    child: Opacity(
                      opacity: 0.95,
                      child: HeynPhoto(asset: photo, fit: BoxFit.cover),
                    ),
                  ),
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: 32,
                    child: CustomPaint(painter: const _BannerChevronsPainter()),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 18, photoWidth - 34, 14),
                    child: Directionality(
                      textDirection: Directionality.of(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              HeynLogoMark.logoPath,
                              width: 72,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: HeynTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.5,
                              height: 1.08,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HeynTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.cartBadge,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                child: Text(
                                  cta,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: HeynTextStyles.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BannerChevronsPainter extends CustomPainter {
  const _BannerChevronsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.primary.withValues(alpha: 0.28);
    for (var i = 0; i < 3; i++) {
      final y = 48.0 + i * 14;
      final path = Path()
        ..moveTo(4, y)
        ..lineTo(14, y + 10)
        ..lineTo(4, y + 20);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ApiStateCard.error(error, l10n),
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
                  l10n.homeCategories,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.darkText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onSeeAll,
                  child: Text(
                    l10n.commonSeeAll,
                    style: HeynTextStyles.caption.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (visible.isEmpty)
              ApiStateCard(
                title: l10n.homeNoCategories,
                icon: Icons.category_outlined,
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: _HomeCategoryTile.tileHeight,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, i) {
                  final category = visible[i];
                  return _HomeCategoryTile(
                    key: ValueKey('home-category-${category.id}'),
                    category: category,
                    label: localizedCategoryLabel(category, l10n),
                    selected: selectedCategoryId == category.id,
                    index: i,
                    onTap: () => onSelected(category.id),
                  );
                },
              ),
            if (selectedCategoryId != null) ...[
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.center,
                child: TextButton(
                  onPressed: () => onSelected(null),
                  child: Text(
                    l10n.commonAll,
                    style: HeynTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HomeCategoryTile extends StatelessWidget {
  const _HomeCategoryTile({
    super.key,
    required this.category,
    required this.label,
    required this.selected,
    required this.index,
    required this.onTap,
  });

  final Category category;
  final String label;
  final bool selected;
  final int index;
  final VoidCallback onTap;

  static const tileHeight = 166.0;
  static const _radius = 18.0;
  static const _padding = 8.0;
  static const _imageHeight = 108.0;
  static const _footerGap = 6.0;
  static const _footerHeight = 34.0;
  static const _footerHorizontalInset = 4.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: InkWell(
                key: ValueKey('home-category-${category.id}-tap'),
                onTap: onTap,
                borderRadius: borderRadius,
                child: Padding(
                  padding: const EdgeInsets.all(_padding),
                  child: Column(
                    children: [
                      SizedBox(
                        height: _imageHeight,
                        width: double.infinity,
                        child: _CategoryImage(category: category, index: index),
                      ),
                      const Spacer(),
                      const SizedBox(height: _footerGap),
                      SizedBox(
                        height: _footerHeight,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _footerHorizontalInset,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.lightTeal,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: HeynTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5,
                                    height: 1,
                                  ),
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
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.category, required this.index});

  final Category category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final asset = HeynMedia.categoryPhotoOverride(category.id);
    final fallback = HeynMedia.categoryPhoto(category.id);
    final radius = BorderRadius.circular(16);
    final imageUrl = category.imageUrl;
    final child = asset != null
        ? HeynPhoto(
            asset: asset,
            width: double.infinity,
            height: double.infinity,
          )
        : imageUrl == null || imageUrl.isEmpty
        ? HeynPhoto(
            asset: fallback,
            width: double.infinity,
            height: double.infinity,
          )
        : Image.network(
            imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => HeynPhoto(
              asset: fallback,
              width: double.infinity,
              height: double.infinity,
            ),
          );

    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: AppColors.categoryTints[index % AppColors.categoryTints.length],
        child: child,
      ),
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
          (needle.isEmpty || _productMatchesQuery(product, needle)))
        product,
  ];
}

bool _productMatchesQuery(Product product, String needle) {
  return product.name.toLowerCase().contains(needle) ||
      product.description.toLowerCase().contains(needle) ||
      product.details.toLowerCase().contains(needle) ||
      product.categoryId.toLowerCase().contains(needle) ||
      product.imageLabel.toLowerCase().contains(needle);
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
    final l10n = AppLocalizations.of(context);
    return products.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ApiStateCard.error(error, l10n),
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
                  ? l10n.homeNoProducts
                  : l10n.commonNoResultsFor(searchQuery),
              icon: Icons.inventory_2_outlined,
            ),
          );
        }
        if (searchQuery.trim().isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 214,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                return _HeynProductCard(
                  key: ValueKey('home-search-${filtered[i].id}'),
                  product: filtered[i],
                  index: i,
                  onTap: () => onOpen(filtered[i]),
                  onAdd: () => onAdd(filtered[i]),
                );
              },
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
              height: 216,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: popular.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  return _HeynProductCard(
                    key: ValueKey('home-product-${popular[i].id}'),
                    product: popular[i],
                    index: i,
                    width: 168,
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
                      foregroundColor: AppColors.darkText,
                      side: const BorderSide(color: AppColors.darkText),
                      backgroundColor: AppColors.chipBackground,
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.grid_view_rounded, size: 16),
                    label: Text(
                      selectedCategoryId != null
                          ? l10n.homeSeeCategoryProducts
                          : l10n.homeSeeCatalog,
                      style: HeynTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkText,
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
                  l10n.homeOtherProducts,
                  style: HeynTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.darkText,
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
                    mainAxisExtent: 214,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, i) {
                    final product = others[i];
                    return _HeynProductCard(
                      key: ValueKey('home-product-${product.id}'),
                      index: i,
                      product: product,
                      onTap: () => onOpen(product),
                      onAdd: () => onAdd(product),
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

class _HeynProductCard extends ConsumerWidget {
  const _HeynProductCard({
    super.key,
    required this.product,
    required this.index,
    required this.onTap,
    required this.onAdd,
    this.width,
  });

  final Product product;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final type = ref.watch(currentClientTypeProvider);
    final canAdd = product.canAddToCart;
    final showWholesale =
        type.isCommercant &&
        (product.saleMode == SaleMode.wholesale ||
            product.saleMode == SaleMode.both);

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductHeroMedia(
                    product: product,
                    index: index,
                    width: double.infinity,
                    height: 118,
                    iconSize: 38,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: HeynTextStyles.bodyMedium.copyWith(
                      height: 1.12,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatOuguiya(product.priceFor(type)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: HeynTextStyles.priceBold.copyWith(
                                color: AppColors.darkText,
                                fontSize: 14,
                              ),
                            ),
                            if (showWholesale)
                              Text(
                                l10n.saleModeWholesale,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HeynTextStyles.caption.copyWith(
                                  color: HeynColors.turquoise,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Material(
                        color: canAdd
                            ? AppColors.darkButton
                            : AppColors.shimmerBase,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: canAdd ? onAdd : null,
                          child: SizedBox.square(
                            dimension: 30,
                            child: Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: canAdd
                                  ? HeynColors.onNavy
                                  : AppColors.mutedText,
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
        ),
      ),
    );
  }
}
