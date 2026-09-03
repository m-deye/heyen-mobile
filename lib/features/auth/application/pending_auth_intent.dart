import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/product.dart';

enum PendingAuthAction { none, addToCart, checkout }

class PendingAuthIntent {
  const PendingAuthIntent({
    required this.redirect,
    this.product,
    this.quantity = 1,
    this.action = PendingAuthAction.none,
  });

  final String redirect;
  final Product? product;
  final int quantity;
  final PendingAuthAction action;
}

class PendingAuthIntentController extends Notifier<PendingAuthIntent?> {
  @override
  PendingAuthIntent? build() => null;

  void remember(PendingAuthIntent intent) => state = intent;

  PendingAuthIntent? take() {
    final current = state;
    state = null;
    return current;
  }

  void clear() => state = null;
}

final pendingAuthIntentProvider =
    NotifierProvider<PendingAuthIntentController, PendingAuthIntent?>(
      PendingAuthIntentController.new,
    );

/// Après « Passer », l'invité peut parcourir accueil / catalogue dans la session.
class GuestBrowseAllowed extends Notifier<bool> {
  @override
  bool build() => false;

  void allow() => state = true;

  void reset() => state = false;
}

final guestBrowseAllowedProvider =
    NotifierProvider<GuestBrowseAllowed, bool>(GuestBrowseAllowed.new);
