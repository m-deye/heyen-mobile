import 'client_type.dart';
import 'order_line.dart';
import 'order_status.dart';
import 'payment_method.dart';

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.status,
    required this.lines,
    required this.deliveryAddress,
    this.paymentMethod,
    this.walletPhone = '',
    this.contactPhone = '',
    this.clientType,
    this.userId = '',
  });

  final String id;
  final DateTime? date;
  final OrderStatus status;
  final List<OrderLine> lines;
  final String deliveryAddress;
  final MobilePaymentMethod? paymentMethod;
  final String walletPhone;
  final String contactPhone;
  final ClientType? clientType;
  final String userId;

  double get total {
    return lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
  }

  double totalFor(ClientType type) {
    return lines.fold<double>(0, (sum, line) => sum + line.lineTotalFor(type));
  }

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      date: date,
      status: status ?? this.status,
      lines: lines,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      walletPhone: walletPhone,
      contactPhone: contactPhone,
      clientType: clientType,
      userId: userId,
    );
  }

  factory Order.fromJson(Map<String, Object?> json) {
    return Order(
      id: _readString(json, ['orderNumber', 'id', 'number', 'reference']),
      date: _readDate(json, ['date', 'created_at', 'createdAt']),
      status: OrderStatus.fromApi(_readString(json, ['status'])),
      deliveryAddress: _readAddress(json),
      paymentMethod: MobilePaymentMethod.fromApi(
        _readString(json, ['payment_method', 'paymentMethod']),
      ),
      walletPhone: _readString(json, ['wallet_phone', 'walletPhone']),
      contactPhone: _readString(json, [
        'phone',
        'contact_phone',
        'contactPhone',
      ]),
      clientType: _readString(json, ['client_type', 'clientType']).isEmpty
          ? null
          : ClientType.fromApi(
              _readString(json, ['client_type', 'clientType']),
            ),
      userId: _readString(json, ['user_id', 'userId']),
      lines: _readLines(json),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'status': status.name,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod?.apiValue,
      'wallet_phone': walletPhone,
      'phone': contactPhone,
      'client_type': clientType?.apiValue,
      'user_id': userId,
      'lines': [for (final line in lines) line.toJson()],
    };
  }

  static List<OrderLine> _readLines(Map<String, Object?> json) {
    final rawLines = switch (json) {
      {'lines': final List<dynamic> lines} => lines,
      {'items': final List<dynamic> items} => items,
      _ => const <dynamic>[],
    };
    return rawLines
        .whereType<Map>()
        .map((item) => OrderLine.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }

  static String _readAddress(Map<String, Object?> json) {
    final direct = _readString(json, [
      'delivery_address',
      'deliveryAddress',
      'notes',
    ]);
    if (direct.isNotEmpty) {
      return direct;
    }
    final address = json['address'];
    if (address is Map) {
      final map = Map<String, Object?>.from(address);
      return [
        _readString(map, ['street']),
        _readString(map, ['district']),
        _readString(map, ['city', 'label']),
      ].where((part) => part.isNotEmpty).join(', ');
    }
    return '';
  }

  static String _readString(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return value.toString();
      }
    }
    return '';
  }

  static DateTime? _readDate(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String) {
        return DateTime.tryParse(value);
      }
    }
    return null;
  }
}
