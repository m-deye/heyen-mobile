import 'package:dio/dio.dart';

import '../../../core/api/api_config.dart';
import '../../../core/api/api_json.dart';
import '../../../shared/models/order_line.dart';

class CartApi {
  const CartApi(this._dio);

  final Dio _dio;

  Future<List<OrderLine>> fetch() async {
    final response = await _dio.get<Object?>(ApiEndpoints.cart);
    return parseCart(response.data);
  }

  Future<List<OrderLine>> add({
    required String productId,
    required int quantity,
  }) async {
    final response = await _dio.post<Object?>(
      ApiEndpoints.cartItems,
      data: {'productId': productId, 'quantity': quantity},
    );
    return parseCart(response.data);
  }

  Future<List<OrderLine>> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    final response = await _dio.patch<Object?>(
      '${ApiEndpoints.cartItems}/$itemId',
      data: {'quantity': quantity},
    );
    return parseCart(response.data);
  }

  Future<List<OrderLine>> remove(String itemId) async {
    final response = await _dio.delete<Object?>(
      '${ApiEndpoints.cartItems}/$itemId',
    );
    return parseCart(response.data);
  }

  Future<void> clear() async {
    await _dio.delete<Object?>(ApiEndpoints.cart);
  }

  Future<List<OrderLine>> replace(List<OrderLine> lines) async {
    await clear();
    List<OrderLine> current = const [];
    for (final line in lines) {
      if (line.quantity < 1 || line.product.cartProductId.isEmpty) {
        continue;
      }
      current = await add(
        productId: line.product.cartProductId,
        quantity: line.quantity,
      );
    }
    return current;
  }

  static List<OrderLine> parseCart(Object? payload) {
    final data = asJsonMap(unwrapApiData(payload));
    final items = data['items'];
    if (items is! List) {
      return const [];
    }

    return [
      for (final item in items)
        if (item is Map) OrderLine.fromJson(Map<String, Object?>.from(item)),
    ];
  }
}
