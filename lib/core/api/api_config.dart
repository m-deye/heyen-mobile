import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String resolveHeynApiBaseUrl() {
  const fromEnv = String.fromEnvironment('HEYN_API_BASE_URL');
  if (fromEnv.trim().isNotEmpty) {
    return fromEnv.trim();
  }

  return 'https://heyen-gust.vercel.app';
}

/// Makes backend media paths loadable on the current device.
String resolveHeynMediaUrl(String raw, {String? apiBaseUrl}) {
  final value = raw.trim();
  if (value.isEmpty) {
    return value;
  }

  final base = (apiBaseUrl ?? resolveHeynApiBaseUrl()).replaceAll(
    RegExp(r'/$'),
    '',
  );
  final parsed = value.startsWith('/')
      ? Uri.tryParse(base.isEmpty ? value : '$base$value')
      : Uri.tryParse(value);
  if (parsed == null || !parsed.hasScheme) {
    return value;
  }

  if (defaultTargetPlatform == TargetPlatform.android &&
      (parsed.host == 'localhost' || parsed.host == '127.0.0.1')) {
    return parsed.replace(host: '10.0.2.2').toString();
  }

  return parsed.toString();
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
