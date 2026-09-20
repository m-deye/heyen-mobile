import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/locale/app_locale_controller.dart';
import '../features/auth/application/auth_navigation.dart';
import '../features/auth/application/auth_session_controller.dart';
import '../features/auth/application/pending_auth_intent.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/cart/presentation/cart_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/catalog/presentation/product_detail_screen.dart';
import '../features/checkout/presentation/checkout_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/onboarding/presentation/language_selection_screen.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'app_shell.dart';

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen<AuthStatus>(authStatusProvider, (previous, next) {
    onAuthStatusChanged(ref, previous, next);
    refresh.ping();
  });
  ref.listen<bool>(guestBrowseAllowedProvider, (_, _) => refresh.ping());
  ref.listen<AppLocaleState>(
    appLocaleControllerProvider,
    (_, _) => refresh.ping(),
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoggedIn =
          ref.read(authStatusProvider) == AuthStatus.authenticated;
      final canBrowseAsGuest = ref.read(guestBrowseAllowedProvider);
      final localeState = ref.read(appLocaleControllerProvider);
      final location = state.matchedLocation;
      final onAuthRoute = isAuthLocation(location);
      final onLanguageRoute = location == '/language';

      if (localeState.isLoading) {
        return null;
      }

      if (!localeState.hasSelectedLocale && !onLanguageRoute) {
        return _languageLocation(redirect: state.uri.toString());
      }

      if (isLoggedIn && onAuthRoute) {
        return pendingOrQueryRedirect(
              ref,
              queryRedirect: state.uri.queryParameters['redirect'],
            ) ??
            '/';
      }

      if (!isLoggedIn && isProtectedLocation(location)) {
        return loginLocation(redirect: state.uri.toString());
      }

      if (!isLoggedIn &&
          !canBrowseAsGuest &&
          !onAuthRoute &&
          !onLanguageRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          return ResetPasswordScreen(
            initialToken: state.uri.queryParameters['token'] ?? '',
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) {
                  return CatalogScreen(
                    selectedCategoryId: state.uri.queryParameters['category'],
                    searchQuery: state.uri.queryParameters['search'],
                  );
                },
                routes: [
                  GoRoute(
                    path: 'product/:productId',
                    builder: (context, state) {
                      return ProductDetailScreen(
                        productId: state.pathParameters['productId']!,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
                routes: [
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

String _languageLocation({required String redirect}) {
  if (redirect == '/language' || redirect.startsWith('/language?')) {
    return '/language';
  }
  return '/language?redirect=${Uri.encodeQueryComponent(redirect)}';
}
