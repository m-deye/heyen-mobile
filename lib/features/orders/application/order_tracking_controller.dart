import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/order.dart';
import '../../../shared/models/order_status.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../checkout/application/checkout_controllers.dart';
import '../data/api_orders_repository.dart';

final orderStatusPollingEnabledProvider = Provider<bool>((ref) => true);

final orderStatusOverridesProvider =
    NotifierProvider<OrderStatusOverrides, Map<String, OrderStatus>>(
      OrderStatusOverrides.new,
    );

final orderPollingTickProvider = NotifierProvider<OrderPollingTick, int>(
  OrderPollingTick.new,
);

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  ref.watch(orderPollingTickProvider);
  final remote = await ref.watch(ordersRepositoryProvider).getOrders();
  final local = ref.watch(localOrdersControllerProvider);
  final overrides = ref.watch(orderStatusOverridesProvider);
  return [
    for (final order in [...local, ...remote])
      order.copyWith(status: overrides[order.id] ?? order.status),
  ];
});

class OrderStatusOverrides extends Notifier<Map<String, OrderStatus>> {
  @override
  Map<String, OrderStatus> build() {
    ref.listen(authSessionControllerProvider, (previous, next) {
      if (previous?.id != next?.id) {
        state = const {};
      }
    });
    return const {};
  }

  void advanceFrom(List<Order> orders) {
    state = {
      for (final order in orders)
        order.id: (state[order.id] ?? order.status).next,
    };
  }
}

class OrderPollingTick extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    if (!ref.watch(orderStatusPollingEnabledProvider)) {
      return 0;
    }

    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(_tick());
    });
    return 0;
  }

  Future<void> _tick() async {
    final remote = await ref.read(ordersRepositoryProvider).getOrders();
    final local = ref.read(localOrdersControllerProvider);
    final merged = [...local, ...remote];
    final overrides = ref.read(orderStatusOverridesProvider);
    final displayedStatuses = [
      for (final order in merged) overrides[order.id] ?? order.status,
    ];
    if (displayedStatuses.every((status) => status.isDelivered)) {
      _timer?.cancel();
      return;
    }

    ref.read(orderStatusOverridesProvider.notifier).advanceFrom(merged);
    state++;
  }
}
