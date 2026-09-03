import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_json.dart';
import '../../../core/api/api_unreachable.dart';
import '../../../core/dev/dev_seed_data.dart';
import '../../../shared/models/client_type.dart';
import '../../../shared/models/order.dart';
import '../../auth/application/auth_session_controller.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final config = ref.watch(apiConfigProvider);
  if (!config.isConfigured) {
    final type =
        ref.watch(authSessionControllerProvider)?.type ??
        ClientType.particulier;
    return DevOrdersRepository(type);
  }

  return ApiOrdersRepository(ref.watch(dioProvider));
});

abstract class OrdersRepository {
  Future<List<Order>> getOrders();
  Future<Order> createOrder(Order order, {String? addressId});
}

class ApiOrdersRepository implements OrdersRepository {
  const ApiOrdersRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get<Object?>(
        ApiEndpoints.orders,
        queryParameters: const {'pageSize': 50},
      );
      return unwrapApiList(response.data).map(Order.fromJson).toList();
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return const [];
      }
      rethrow;
    }
  }

  @override
  Future<Order> createOrder(Order order, {String? addressId}) async {
    try {
      final notes = [
        order.deliveryAddress,
        if (order.paymentMethod != null) order.paymentMethod!.label,
        if (order.contactPhone.isNotEmpty) order.contactPhone,
      ].where((part) => part.isNotEmpty).join(' · ');
      final response = await _dio.post<Object?>(
        ApiEndpoints.orders,
        data: {
          if (addressId != null && addressId.isNotEmpty) 'addressId': addressId,
          if (notes.isNotEmpty) 'notes': notes,
        },
      );
      final data = asJsonMap(unwrapApiData(response.data));
      if (data.isEmpty) {
        return order;
      }
      return Order.fromJson(data);
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return order;
      }
      rethrow;
    }
  }
}

class DevOrdersRepository implements OrdersRepository {
  const DevOrdersRepository(this.clientType);

  final ClientType clientType;

  @override
  Future<List<Order>> getOrders() async => DevSeedData.ordersFor(clientType);

  @override
  Future<Order> createOrder(Order order, {String? addressId}) async => order;
}
