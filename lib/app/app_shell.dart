import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/heyn_colors.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../features/auth/application/auth_navigation.dart';
import '../features/auth/application/auth_session_controller.dart';
import '../features/cart/application/cart_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const items = [
    BottomNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Accueil',
    ),
    BottomNavItem(
      icon: Icons.category_outlined,
      selectedIcon: Icons.category_rounded,
      label: 'Catégories',
    ),
    BottomNavItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart_rounded,
      label: 'Panier',
    ),
    BottomNavItem(
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment_rounded,
      label: 'Commandes',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemsCountProvider);

    return Scaffold(
      body: navigationShell,
      backgroundColor: HeynColors.pageMint,
      bottomNavigationBar: BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        cartCount: cartCount,
        items: items,
        onTap: (index) {
          const protectedTabs = {2: '/cart', 3: '/orders', 4: '/profile'};
          final protectedPath = protectedTabs[index];
          if (protectedPath != null &&
              ref.read(authStatusProvider) == AuthStatus.guest) {
            requireAuthThen(
              context: context,
              ref: ref,
              redirect: protectedPath,
            );
            return;
          }

          navigationShell.goBranch(
            index,
            initialLocation:
                index == 1 ||
                index == 2 ||
                index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
