import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String resolveHeynApiBaseUrl() {
  const fromEnv = String.fromEnvironment('HEYN_API_BASE_URL');
  if (fromEnv.trim().isNotEmpty) {
    return fromEnv.trim();
  }

  if (kReleaseMode) {
    return '';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }

  return 'http://127.0.0.1:3000';
}

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return ApiConfig(baseUrl: resolveHeynApiBaseUrl());
});

class ApiConfig {
  const ApiConfig({required this.baseUrl});

  final String baseUrl;

  bool get isConfigured => baseUrl.trim().isNotEmpty;
}

class ApiEndpoints {
  const ApiEndpoints._();

  static const health = '/api/health';
  static const login = '/api/auth/login';
  static const register = '/api/auth/register';
  static const refresh = '/api/auth/refresh';
  static const logout = '/api/auth/logout';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';
  static const me = '/api/users/me';
  static const profile = '/api/users/me';
  static const addresses = '/api/users/me/addresses';
  static const categories = '/api/categories';
  static const products = '/api/products';
  static const cart = '/api/cart';
  static const cartItems = '/api/cart/items';
  static const orders = '/api/orders';
}
