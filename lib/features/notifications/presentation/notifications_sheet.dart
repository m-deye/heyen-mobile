import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/order.dart';
import '../../../theme/heyn_theme.dart';
import '../../auth/application/auth_navigation.dart';
import '../../auth/application/auth_session_controller.dart';
import '../../orders/application/order_tracking_controller.dart';

class OrderNotificationItem {
  const OrderNotificationItem({
    required this.title,
    required this.subtitle,
    required this.orderId,
  });

  final String title;
  final String subtitle;
  final String orderId;
}

final orderNotificationsProvider = Provider<List<OrderNotificationItem>>((ref) {
  final user = ref.watch(authSessionControllerProvider);
  if (user == null) {
    return const [];
  }
  final orders = ref.watch(ordersProvider).value ?? const <Order>[];
  return [
    for (final order in orders)
      if (!order.status.isDelivered)
        OrderNotificationItem(
          title: 'Commande ${order.id}',
          subtitle: order.status.label,
          orderId: order.id,
        ),
  ];
});

Future<void> openNotifications(BuildContext context, WidgetRef ref) {
  return requireAuthThen(
    context: context,
    ref: ref,
    redirect: '/orders',
    onAuthorized: () => showOrderNotificationsSheet(context, ref),
  );
}

Future<void> showOrderNotificationsSheet(BuildContext context, WidgetRef ref) {
  final items = ref.read(orderNotificationsProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: HeynColors.creamCard,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: HeynColors.silverStart,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Notifications', style: HeynTextStyles.sectionTitle),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  'Aucune notification pour le moment.',
                  textAlign: TextAlign.center,
                  style: HeynTextStyles.subtitle,
                ),
              )
            else
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.local_shipping_outlined,
                    color: HeynColors.navy,
                  ),
                  title: Text(item.title, style: HeynTextStyles.bodyMedium),
                  subtitle: Text(item.subtitle, style: HeynTextStyles.caption),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.go('/orders');
                  },
                ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/orders');
              },
              child: const Text('Voir les commandes'),
            ),
          ],
        ),
      );
    },
  );
}
