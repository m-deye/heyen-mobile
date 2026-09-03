import 'client_type.dart';
import 'product.dart';

class OrderLine {
  const OrderLine({
    required this.product,
    required this.quantity,
    this.remoteId = '',
  });

  final Product product;
  final int quantity;
  final String remoteId;

  double get lineTotal => product.discountedPrice * quantity;

  double lineTotalFor(ClientType type) => product.priceFor(type) * quantity;

  OrderLine copyWith({Product? product, int? quantity, String? remoteId}) {
    return OrderLine(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  factory OrderLine.fromJson(Map<String, Object?> json) {
    final rawProduct = json['product'];
    final productJson = rawProduct is Map
        ? Map<String, Object?>.from(rawProduct)
        : json;
    final remoteId = rawProduct is Map ? (json['id']?.toString() ?? '') : '';
    return OrderLine(
      product: Product.fromJson(productJson),
      quantity: _readInt(json, ['quantity', 'qty']),
      remoteId: remoteId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'product': product.toJson(),
      'product_id': product.cartProductId,
      'quantity': quantity,
    };
  }

  static int _readInt(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
    }
    return 0;
  }
}
