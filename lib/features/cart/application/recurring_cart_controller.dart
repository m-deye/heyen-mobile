import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dev/dev_seed_data.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/models/recurring_cart.dart';
import '../../auth/application/auth_session_controller.dart';

final recurringCartControllerProvider =
    NotifierProvider<RecurringCartController, RecurringCart?>(
      RecurringCartController.new,
    );

class RecurringCartController extends Notifier<RecurringCart?> {
  @override
  RecurringCart? build() {
    ref.listen(authSessionControllerProvider, (previous, next) {
      if (previous?.id != next?.id) {
        state = next?.isCommercant == true
            ? DevSeedData.merchantWeeklyCart
            : null;
      }
    });

    final user = ref.watch(authSessionControllerProvider);
    return user?.isCommercant == true ? DevSeedData.merchantWeeklyCart : null;
  }

  void saveFrom(List<OrderLine> lines, {String name = 'Panier type hebdo'}) {
    if (lines.isEmpty) {
      return;
    }

    state = RecurringCart(
      name: name,
      lines: [for (final line in lines) line.copyWith()],
      updatedAt: DateTime.now(),
    );
  }

  void clear() {
    state = null;
  }
}
