import 'client_type.dart';
import 'delivery_location.dart';
import 'order_line.dart';
import 'payment_method.dart';

enum QuoteStatus {
  pending,
  approved,
  rejected;

  String get label => switch (this) {
    QuoteStatus.pending => 'En attente admin',
    QuoteStatus.approved => 'Devis validé',
    QuoteStatus.rejected => 'Devis refusé',
  };

  static QuoteStatus fromApi(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    return switch (normalized) {
      'approved' || 'valide' || 'validé' => QuoteStatus.approved,
      'rejected' || 'refuse' || 'refusé' => QuoteStatus.rejected,
      _ => QuoteStatus.pending,
    };
  }
}

class Quote {
  const Quote({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.lines,
    required this.shopName,
    required this.deliveryLocation,
    required this.paymentMethod,
    required this.walletPhone,
    this.whatsApp = '',
  });

  final String id;
  final DateTime createdAt;
  final QuoteStatus status;
  final List<OrderLine> lines;
  final String shopName;
  final DeliveryLocation deliveryLocation;
  final MobilePaymentMethod paymentMethod;
  final String walletPhone;
  final String whatsApp;

  double totalFor(ClientType type) {
    return lines.fold<double>(0, (sum, line) => sum + line.lineTotalFor(type));
  }

  Quote copyWith({QuoteStatus? status}) {
    return Quote(
      id: id,
      createdAt: createdAt,
      status: status ?? this.status,
      lines: lines,
      shopName: shopName,
      deliveryLocation: deliveryLocation,
      paymentMethod: paymentMethod,
      walletPhone: walletPhone,
      whatsApp: whatsApp,
    );
  }

  factory Quote.fromJson(Map<String, Object?> json) {
    final locationJson = json['delivery_location'] ?? json['deliveryLocation'];
    return Quote(
      id: json['id']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      status: QuoteStatus.fromApi(json['status']?.toString()),
      shopName:
          json['shop_name']?.toString() ?? json['shopName']?.toString() ?? '',
      deliveryLocation: locationJson is Map<String, Object?>
          ? DeliveryLocation.fromJson(locationJson)
          : locationJson is Map
          ? DeliveryLocation.fromJson(Map<String, Object?>.from(locationJson))
          : const DeliveryLocation(
              neighborhood: '',
              landmark: '',
              latitude: 0,
              longitude: 0,
            ),
      paymentMethod:
          MobilePaymentMethod.fromApi(
            json['payment_method']?.toString() ??
                json['paymentMethod']?.toString(),
          ) ??
          MobilePaymentMethod.bankily,
      walletPhone:
          json['wallet_phone']?.toString() ??
          json['walletPhone']?.toString() ??
          '',
      whatsApp:
          json['whatsapp']?.toString() ?? json['whatsApp']?.toString() ?? '',
      lines: _readLines(json),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'shop_name': shopName,
      'delivery_location': deliveryLocation.toJson(),
      'payment_method': paymentMethod.apiValue,
      'wallet_phone': walletPhone,
      'whatsapp': whatsApp,
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
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => OrderLine.fromJson(Map<String, Object?>.from(item)))
        .toList();
  }
}
