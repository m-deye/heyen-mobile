import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/client_type.dart';
import '../../../shared/models/delivery_location.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/payment_method.dart';
import '../../../shared/models/quote.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../orders/data/local_order_store.dart';

final quotesControllerProvider =
    NotifierProvider<QuotesController, List<Quote>>(QuotesController.new);

final localOrdersControllerProvider =
    NotifierProvider<LocalOrdersController, List<Order>>(
      LocalOrdersController.new,
    );

class QuotesController extends Notifier<List<Quote>> {
  final _store = const LocalOrderStore();

  String get _userId => ref.read(authSessionControllerProvider)?.id ?? '';

  @override
  List<Quote> build() {
    ref.listen(authSessionControllerProvider, (previous, next) {
      if (previous?.id != next?.id) {
        state = const [];
        unawaited(_load());
      }
    });
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    final stored = await _store.loadQuotes(_userId);
    if (!ref.mounted || stored.isEmpty) {
      return;
    }
    final existingIds = {for (final quote in state) quote.id};
    state = [
      ...state,
      for (final quote in stored)
        if (!existingIds.contains(quote.id)) quote,
    ];
  }

  Future<void> _persist() {
    return _store.saveQuotes(_userId, state);
  }

  Quote create({
    required List<OrderLine> lines,
    required String shopName,
    required DeliveryLocation deliveryLocation,
    required MobilePaymentMethod paymentMethod,
    required String walletPhone,
    required String whatsApp,
  }) {
    final quote = Quote(
      id: 'DEVIS-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      status: QuoteStatus.pending,
      lines: [for (final line in lines) line.copyWith()],
      shopName: shopName,
      deliveryLocation: deliveryLocation,
      paymentMethod: paymentMethod,
      walletPhone: walletPhone,
      whatsApp: whatsApp,
    );
    state = [quote, ...state];
    unawaited(_persist());
    return quote;
  }

  void approve(String quoteId) {
    state = [
      for (final quote in state)
        if (quote.id == quoteId)
          quote.copyWith(status: QuoteStatus.approved)
        else
          quote,
    ];
    unawaited(_persist());
  }

  void reject(String quoteId) {
    state = [
      for (final quote in state)
        if (quote.id == quoteId)
          quote.copyWith(status: QuoteStatus.rejected)
        else
          quote,
    ];
    unawaited(_persist());
  }

  void remove(String quoteId) {
    state = [
      for (final quote in state)
        if (quote.id != quoteId) quote,
    ];
    unawaited(_persist());
  }
}

class LocalOrdersController extends Notifier<List<Order>> {
  final _store = const LocalOrderStore();

  String get _userId => ref.read(authSessionControllerProvider)?.id ?? '';

  @override
  List<Order> build() {
    ref.listen(authSessionControllerProvider, (previous, next) {
      if (previous?.id != next?.id) {
        state = const [];
        unawaited(_load());
      }
    });
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    final stored = await _store.loadOrders(_userId);
    if (!ref.mounted || stored.isEmpty) {
      return;
    }
    final existingIds = {for (final order in state) order.id};
    state = [
      ...state,
      for (final order in stored)
        if (!existingIds.contains(order.id)) order,
    ];
  }

  Future<void> _persist() {
    return _store.saveOrders(_userId, state);
  }

  Order add({
    required List<OrderLine> lines,
    required DeliveryLocation deliveryLocation,
    required MobilePaymentMethod paymentMethod,
    required String walletPhone,
    required String contactPhone,
    required ClientType clientType,
    String userId = '',
    OrderStatus status = OrderStatus.confirmee,
  }) {
    final order = Order(
      id: 'CMD-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      status: status,
      lines: [for (final line in lines) line.copyWith()],
      deliveryAddress: deliveryLocation.formattedAddress,
      paymentMethod: paymentMethod,
      walletPhone: walletPhone,
      contactPhone: contactPhone,
      clientType: clientType,
      userId: userId.isNotEmpty ? userId : _userId,
    );
    state = [order, ...state];
    unawaited(_persist());
    return order;
  }

  Order addFromQuote(Quote quote) {
    return add(
      lines: quote.lines,
      deliveryLocation: quote.deliveryLocation,
      paymentMethod: quote.paymentMethod,
      walletPhone: quote.walletPhone,
      contactPhone: quote.deliveryLocation.phone,
      clientType: ClientType.commercant,
      status: OrderStatus.enPreparation,
    );
  }
}
