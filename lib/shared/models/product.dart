import 'client_type.dart';
import 'sale_mode.dart';

class Product {
  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.description,
    required this.details,
    required this.status,
    this.apiId = '',
    this.discountPercent = 0,
    this.imageLabel = '',
    this.saleMode = SaleMode.unit,
    this.imageUrl,
    this.badges = const [],
    this.stock = 0,
  });

  final String id;

  /// UUID Heyen, utilise pour le panier API. [id] reste le slug pour les routes.
  final String apiId;
  final String categoryId;
  final String name;
  final double price;
  final String description;
  final String details;
  final String status;
  final int discountPercent;
  final String imageLabel;
  final SaleMode saleMode;
  final String? imageUrl;
  final List<String> badges;
  final int stock;

  String get category => categoryId;

  bool get isOutOfStock => stock <= 0;

  bool get hasLimitedStock => stock > 0 && stock <= 10;

  bool get canAddToCart => stock > 0;

  String get stockLabel {
    if (stock <= 0) {
      return 'Rupture';
    }
    if (stock <= 10) {
      return 'Stock limité';
    }
    return 'Disponible';
  }

  List<String> get displayBadges {
    final labels = <String>[
      stockLabel,
      if (hasDiscount) 'Promo',
      if (saleMode.soldWholesale) 'Prix gros',
    ];
    final normalized = status.toLowerCase();
    if (normalized.contains('nouveau') && !labels.contains('Nouveau')) {
      labels.add('Nouveau');
    }
    for (final badge in badges) {
      if (badge.trim().isNotEmpty &&
          !labels.any((label) => label.toLowerCase() == badge.toLowerCase())) {
        labels.add(badge);
      }
    }
    return labels;
  }

  String get cartProductId => apiId.isNotEmpty ? apiId : id;

  bool get hasDiscount => discountPercent > 0;

  double get discountedPrice {
    if (!hasDiscount) {
      return price;
    }

    return price * (1 - discountPercent / 100);
  }

  double priceFor(ClientType type) {
    final base = discountedPrice;
    if (!type.isCommercant || !saleMode.soldWholesale) {
      return base;
    }

    return base * (1 - ClientType.wholesaleDiscountPercent / 100);
  }

  factory Product.fromJson(Map<String, Object?> json) {
    final uuid = _readString(json, ['id', 'product_id', 'productId']);
    final slug = _readString(json, ['slug']);
    return Product(
      id: slug.isNotEmpty ? slug : uuid,
      apiId: uuid,
      categoryId: _readCategoryId(json),
      name: _readString(json, ['name', 'title', 'product_name', 'productName']),
      price: _readDouble(json, ['price', 'unit_price', 'unitPrice']),
      description: _readString(json, ['description']),
      details: _readString(json, ['details']),
      status: _readString(json, ['status']),
      discountPercent: _readInt(json, ['discount_percent', 'discountPercent']),
      imageLabel: _readString(json, ['image_label', 'imageLabel']),
      saleMode: SaleMode.fromApi(
        _readString(json, ['sale_mode', 'saleMode', 'sold_by', 'soldBy']),
      ),
      imageUrl: () {
        final url = _readString(json, ['imageUrl', 'image_url', 'image']);
        return url.isEmpty ? null : url;
      }(),
      badges: _readStringList(json, ['badges']),
      stock: _readInt(json, ['stock', 'quantity', 'qty']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': apiId.isNotEmpty ? apiId : id,
      'slug': id,
      'category_id': categoryId,
      'name': name,
      'price': price,
      'description': description,
      'details': details,
      'status': status,
      'discount_percent': discountPercent,
      'image_label': imageLabel,
      'sale_mode': saleMode.apiValue,
      'image_url': imageUrl,
      'badges': badges,
      'stock': stock,
    };
  }

  Product copyWith({int? stock, String? status}) {
    return Product(
      id: id,
      apiId: apiId,
      categoryId: categoryId,
      name: name,
      price: price,
      description: description,
      details: details,
      status: status ?? this.status,
      discountPercent: discountPercent,
      imageLabel: imageLabel,
      saleMode: saleMode,
      imageUrl: imageUrl,
      badges: badges,
      stock: stock ?? this.stock,
    );
  }

  static String _readCategoryId(Map<String, Object?> json) {
    final category = json['category'];
    if (category is Map) {
      final nested = _readString(Map<String, Object?>.from(category), [
        'slug',
        'id',
      ]);
      if (nested.isNotEmpty) {
        return nested;
      }
    }
    final slug = _readString(json, ['categorySlug', 'category_slug']);
    if (slug.isNotEmpty) {
      return slug;
    }
    return _readString(json, ['category_id', 'categoryId', 'category']);
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

  static double _readDouble(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value) ?? 0;
      }
    }
    return 0;
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

  static List<String> _readStringList(
    Map<String, Object?> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        return [
          for (final item in value)
            if (item != null && item.toString().trim().isNotEmpty)
              item.toString(),
        ];
      }
    }
    return const [];
  }
}
