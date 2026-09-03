import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_unreachable.dart';
import '../../../shared/models/order_line.dart';
import '../../../shared/models/product.dart';
import '../../auth/application/auth_session_controller.dart';
import '../data/cart_api.dart';

final cartControllerProvider =
    NotifierProvider<CartController, List<OrderLine>>(CartController.new);

final cartTotalProvider = Provider<double>((ref) {
  final lines = ref.watch(cartControllerProvider);
  final type = ref.watch(currentClientTypeProvider);
  return lines.fold<double>(
    0,
    (total, line) => total + line.lineTotalFor(type),
  );
});

final cartItemsCountProvider = Provider<int>((ref) {
  final lines = ref.watch(cartControllerProvider);
  return lines.fold<int>(0, (total, line) => total + line.quantity);
});

class CartController extends Notifier<List<OrderLine>> {
  @override
  List<OrderLine> build() {
    ref.listen(authSessionControllerProvider, (previous, next) {
      if (next == null) {
        state = const [];
        return;
      }
      if (previous?.id != next.id) {
        unawaited(_hydrateFromApi());
      }
    });
    return const [];
  }

  void addProduct(Product product, {int quantity = 1}) {
    if (!product.canAddToCart) {
      return;
    }
    final requested = quantity < 1 ? 1 : quantity;
    final index = state.indexWhere((line) => line.product.id == product.id);
    final already = index == -1 ? 0 : state[index].quantity;
    final remaining = product.stock - already;
    if (remaining <= 0) {
      return;
    }
    final addBy = requested > remaining ? remaining : requested;
    if (index == -1) {
      state = [...state, OrderLine(product: product, quantity: addBy)];
    } else {
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + addBy)
          else
            state[i],
      ];
    }
    unawaited(
      _runRemote(
        (api) => api.add(productId: product.cartProductId, quantity: addBy),
      ),
    );
  }

  void increment(String productId) {
    final current = _lineByProduct(productId);
    if (current == null) {
      return;
    }
    if (current.product.stock > 0 &&
        current.quantity >= current.product.stock) {
      return;
    }
    final updated = current.copyWith(quantity: current.quantity + 1);
    _replaceLine(updated);
    unawaited(_syncLine(updated));
  }

  void decrement(String productId) {
    final current = _lineByProduct(productId);
    if (current == null) {
      return;
    }
    if (current.quantity <= 1) {
      remove(productId);
      return;
    }
    final updated = current.copyWith(quantity: current.quantity - 1);
    _replaceLine(updated);
    unawaited(_syncLine(updated));
  }

  void remove(String productId) {
    final current = _lineByProduct(productId);
    state = [
      for (final line in state)
        if (line.product.id != productId) line,
    ];
    if (current != null && current.remoteId.isNotEmpty) {
      unawaited(_runRemote((api) => api.remove(current.remoteId)));
    }
  }

  void clear() {
    state = const [];
    unawaited(
      _runRemote((api) async {
        await api.clear();
        return const [];
      }),
    );
  }

  void replaceLines(List<OrderLine> lines) {
    state = [
      for (final line in lines)
        if (line.product.canAddToCart)
          line.copyWith(
            quantity: line.quantity > line.product.stock
                ? line.product.stock
                : line.quantity,
          ),
    ];
  }

  Future<void> syncToRemote() async {
    final snapshot = [...state];
    if (snapshot.isEmpty) {
      await _runRemote((api) async {
        await api.clear();
        return const [];
      });
      return;
    }
    await _runRemote((api) => api.replace(snapshot));
  }

  OrderLine? _lineByProduct(String productId) {
    for (final line in state) {
      if (line.product.id == productId) {
        return line;
      }
    }
    return null;
  }

  void _replaceLine(OrderLine updated) {
    state = [
      for (final line in state)
        if (line.product.id == updated.product.id) updated else line,
    ];
  }

  Future<void> _hydrateFromApi() async {
    await _runRemote((api) => api.fetch());
  }

  Future<void> _syncLine(OrderLine line) async {
    if (line.remoteId.isNotEmpty) {
      await _runRemote(
        (api) =>
            api.updateQuantity(itemId: line.remoteId, quantity: line.quantity),
      );
      return;
    }
    await _runRemote(
      (api) => api.add(
        productId: line.product.cartProductId,
        quantity: line.quantity,
      ),
    );
  }

  Future<void> _runRemote(
    Future<List<OrderLine>> Function(CartApi api) action,
  ) async {
    if (!ref.read(apiConfigProvider).isConfigured) {
      return;
    }
    final token = await ref.read(authTokenStoreProvider).readAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final lines = await action(CartApi(ref.read(dioProvider)));
      state = lines;
    } on DioException catch (error) {
      if (!isApiUnreachable(error)) {
        return;
      }
    } catch (_) {}
  }
}
