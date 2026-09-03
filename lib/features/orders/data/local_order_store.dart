import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/order.dart';
import '../../../shared/models/quote.dart';

class LocalOrderStore {
  const LocalOrderStore();

  static String _ordersKey(String userId) => 'heyn.orders.$userId';
  static String _quotesKey(String userId) => 'heyn.quotes.$userId';

  Future<List<Order>> loadOrders(String userId) async {
    if (userId.isEmpty) {
      return const [];
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => Order.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }

  Future<void> saveOrders(String userId, List<Order> orders) async {
    if (userId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _ordersKey(userId),
      jsonEncode([for (final order in orders) order.toJson()]),
    );
  }

  Future<List<Quote>> loadQuotes(String userId) async {
    if (userId.isEmpty) {
      return const [];
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_quotesKey(userId));
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }
    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => Quote.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }

  Future<void> saveQuotes(String userId, List<Quote> quotes) async {
    if (userId.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _quotesKey(userId),
      jsonEncode([for (final quote in quotes) quote.toJson()]),
    );
  }
}
