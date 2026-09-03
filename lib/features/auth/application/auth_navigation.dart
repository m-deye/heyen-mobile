import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/product.dart';
import '../../cart/application/cart_controller.dart';
import '../presentation/guest_auth_sheet.dart';
import 'auth_session_controller.dart';
import 'pending_auth_intent.dart';

const _authPrefixes = [
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
];

bool isProtectedLocation(String location) {
  return location == '/cart' ||
      location.startsWith('/cart/') ||
      location == '/orders' ||
      location.startsWith('/orders/') ||
      location == '/profile' ||
      location.startsWith('/profile/');
}

bool isAuthLocation(String location) {
  return _authPrefixes.any(
    (prefix) => location == prefix || location.startsWith('$prefix/'),
  );
}

String? safePostAuthRedirect(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  var decoded = raw.trim();
  try {
    decoded = Uri.decodeComponent(decoded);
  } catch (_) {}

  if (!decoded.startsWith('/') || decoded.startsWith('//')) {
    return null;
  }
  if (isAuthLocation(decoded)) {
    return null;
  }
  return decoded;
}

String loginLocation({String? redirect}) {
  final target = safePostAuthRedirect(redirect);
  if (target == null) {
    return '/login';
  }
  return '/login?redirect=${Uri.encodeQueryComponent(target)}';
}

String registerLocation({String? redirect}) {
  final target = safePostAuthRedirect(redirect);
  if (target == null) {
    return '/register';
  }
  return '/register?redirect=${Uri.encodeQueryComponent(target)}';
}

String forgotPasswordLocation({String? redirect}) {
  final target = safePostAuthRedirect(redirect);
  if (target == null) {
    return '/forgot-password';
  }
  return '/forgot-password?redirect=${Uri.encodeQueryComponent(target)}';
}

String? pendingOrQueryRedirect(Ref ref, {String? queryRedirect}) {
  return safePostAuthRedirect(queryRedirect) ??
      safePostAuthRedirect(ref.read(pendingAuthIntentProvider)?.redirect);
}

Future<void> requireAuthThen({
  required BuildContext context,
  required WidgetRef ref,
  required String redirect,
  Product? addProduct,
  int quantity = 1,
  PendingAuthAction action = PendingAuthAction.none,
  VoidCallback? onAuthorized,
}) async {
  if (ref.read(authStatusProvider) == AuthStatus.authenticated) {
    onAuthorized?.call();
    return;
  }

  final resolvedAction = addProduct != null && action == PendingAuthAction.none
      ? PendingAuthAction.addToCart
      : action;
  final redirectTo = safePostAuthRedirect(redirect) ?? '/';

  ref
      .read(pendingAuthIntentProvider.notifier)
      .remember(
        PendingAuthIntent(
          redirect: redirectTo,
          product: addProduct,
          quantity: quantity < 1 ? 1 : quantity,
          action: resolvedAction,
        ),
      );

  if (!context.mounted) {
    return;
  }

  final result = await showGuestAuthSheet(context);
  if (!context.mounted) {
    return;
  }

  switch (result) {
    case GuestAuthSheetResult.authenticated:
      _resumeAfterSheetAuth(
        context: context,
        ref: ref,
        redirectTo: redirectTo,
        addProduct: addProduct,
        action: resolvedAction,
        onAuthorized: onAuthorized,
      );
    case GuestAuthSheetResult.createAccount:
      context.push(registerLocation(redirect: redirectTo));
    case GuestAuthSheetResult.forgotPassword:
      context.push(forgotPasswordLocation(redirect: redirectTo));
    case GuestAuthSheetResult.dismissed:
    case null:
      ref.read(pendingAuthIntentProvider.notifier).clear();
  }
}

void _resumeAfterSheetAuth({
  required BuildContext context,
  required WidgetRef ref,
  required String redirectTo,
  required Product? addProduct,
  required PendingAuthAction action,
  required VoidCallback? onAuthorized,
}) {
  if (ref.read(authStatusProvider) != AuthStatus.authenticated) {
    return;
  }

  _addPendingProductToCart(ref);
  final leftover = ref.read(pendingAuthIntentProvider.notifier).take();
  final destination = leftover?.redirect ?? redirectTo;

  if (addProduct != null) {
    if (action == PendingAuthAction.checkout) {
      context.go(destination);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${addProduct.name} ajouté au panier')),
    );
    return;
  }

  if (onAuthorized != null) {
    onAuthorized();
    return;
  }

  context.go(destination);
}

void _addPendingProductToCart(WidgetRef ref) {
  final intent = ref.read(pendingAuthIntentProvider);
  if (intent?.product == null) {
    return;
  }

  ref.read(cartControllerProvider.notifier).addProduct(
    intent!.product!,
    quantity: intent.quantity,
  );
  ref.read(pendingAuthIntentProvider.notifier).remember(
    PendingAuthIntent(redirect: intent.redirect, action: intent.action),
  );
}

void consumePendingAuthIntent(Ref ref) {
  final intent = ref.read(pendingAuthIntentProvider);
  if (intent?.product == null) {
    return;
  }

  ref.read(cartControllerProvider.notifier).addProduct(
    intent!.product!,
    quantity: intent.quantity,
  );
  ref.read(pendingAuthIntentProvider.notifier).remember(
    PendingAuthIntent(redirect: intent.redirect, action: intent.action),
  );
}

void onAuthStatusChanged(Ref ref, AuthStatus? previous, AuthStatus next) {
  if (previous != AuthStatus.authenticated &&
      next == AuthStatus.authenticated) {
    consumePendingAuthIntent(ref);
  }
  if (previous == AuthStatus.authenticated && next == AuthStatus.guest) {
    ref.read(pendingAuthIntentProvider.notifier).clear();
    ref.read(guestBrowseAllowedProvider.notifier).reset();
  }
}

void completePostAuthNavigation(BuildContext context, WidgetRef ref) {
  if (!context.mounted) {
    return;
  }
  _addPendingProductToCart(ref);
  final queryRedirect = safePostAuthRedirect(
    GoRouterState.of(context).uri.queryParameters['redirect'],
  );
  final pending = ref.read(pendingAuthIntentProvider.notifier).take();
  context.go(
    queryRedirect ?? safePostAuthRedirect(pending?.redirect) ?? '/',
  );
}

void closeAuthWithoutLogin(BuildContext context, WidgetRef ref) {
  ref.read(guestBrowseAllowedProvider.notifier).allow();
  ref.read(pendingAuthIntentProvider.notifier).clear();
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go('/');
}

void skipAuthToHome(BuildContext context, WidgetRef ref) {
  ref.read(guestBrowseAllowedProvider.notifier).allow();
  ref.read(pendingAuthIntentProvider.notifier).clear();
  context.go('/');
}
