import 'package:flutter/material.dart';

import '../../../core/widgets/status_timeline.dart';
import '../../../shared/models/order_status.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({super.key, required this.currentStatus});

  final OrderStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    return StatusTimeline(currentStatus: currentStatus);
  }
}
