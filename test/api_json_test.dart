import 'dart:convert';

import 'package:ecommerce_app/core/api/api_json.dart';
import 'package:ecommerce_app/shared/models/category.dart';
import 'package:ecommerce_app/shared/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const liveProductsJson = '''
{"success":true,"data":{"items":[{"id":"cmv8rsa7v000306jzh3prm045","name":"Huile tournesol 1 L","slug":"huile-tournesol-1-l","description":"Huile de tournesol 1 litre","price":"420","unit":"litre","stock":60,"imageUrl":"https://raw.githubusercontent.com/m-deye/heyen-mobile/main/assets/images/products/huile-tournesol-1l.png","saleMode":"RETAIL","wholesalePrice":null,"promoPrice":null,"discountPercent":null,"badges":[],"details":null,"imageLabel":null,"isActive":true,"categoryId":"cmv58dal2000aj0vfpjcmtv7s","createdAt":"2026-10-14T23:57:41.179Z","updatedAt":"2026-10-14T23:57:41.179Z","category":{"id":"cmv58dal2000aj0vfpjcmtv7s","name":"Huile","slug":"huile","description":"Tous les types de huiles","imageUrl":"https://raw.githubusercontent.com/m-deye/heyen-mobile/main/assets/images/products/huile-tournesol-1l.png","isActive":true,"createdAt":"2026-10-12T12:30:50.582Z","updatedAt":"2026-10-13T22:32:50.327Z"},"status":"AVAILABLE","effectivePrice":420}],"pagination":{"page":1,"pageSize":50,"total":1,"totalPages":1}}}
''';

  const liveCategoriesJson = '''
{"success":true,"data":[{"id":"cmv58daie0009j0vf6gp99il9","name":"Boissons","slug":"boissons","description":"Eaux, jus et sodas","imageUrl":"https://placehold.co/600x400?text=Boissons","isActive":true},{"id":"cmv58dal2000aj0vfpjcmtv7s","name":"Huile","slug":"huile","description":"Tous les types de huiles","isActive":true}]}
''';

  test(
    'unwrapApiList reads paginated data.items from the live products shape',
    () {
      final payload = jsonDecode(liveProductsJson);
      final items = unwrapApiList(payload);
      expect(items, hasLength(1));
      expect(items.first['name'], 'Huile tournesol 1 L');
    },
  );

  test(
    'unwrapApiList reads a raw data array from the live categories shape',
    () {
      final payload = jsonDecode(liveCategoriesJson);
      final items = unwrapApiList(payload);
      expect(items.map((item) => item['slug']), ['boissons', 'huile']);
    },
  );

  test('unwrapApiList reads items even when typed as List<Map>', () {
    final payload = <String, Object?>{
      'success': true,
      'data': <String, Object?>{
        'items': <Map<String, Object?>>[
          {'name': 'Huile tournesol 1 L'},
        ],
        'pagination': <String, Object?>{'page': 1},
      },
    };
    expect(unwrapApiList(payload), hasLength(1));
  });

  test('Product.fromJson prefers nested category.slug over the CUID', () {
    final payload = jsonDecode(liveProductsJson);
    final product = Product.fromJson(unwrapApiList(payload).first);
    expect(product.categoryId, 'huile');
    expect(product.categoryApiId, 'cmv58dal2000aj0vfpjcmtv7s');
    expect(product.name, 'Huile tournesol 1 L');
    expect(product.price, 420);
  });

  test('catalog filter matches huile by slug or Prisma CUID', () {
    final categories = unwrapApiList(jsonDecode(liveCategoriesJson)).map((
      json,
    ) {
      return Category(
        id: '${json['slug']}',
        apiId: '${json['id']}',
        label: '${json['name']}',
        description: '${json['description']}',
        imageLabel: 'Hui',
      );
    }).toList();
    final product = Product.fromJson(
      unwrapApiList(jsonDecode(liveProductsJson)).first,
    );
    final huile = categories.firstWhere((category) => category.id == 'huile');

    expect(product.belongsToCategory(huile), isTrue);
    expect(huile.matchesProduct(categoryId: 'huile'), isTrue);
    expect(
      huile.matchesProduct(categoryId: 'cmv58dal2000aj0vfpjcmtv7s'),
      isTrue,
    );
    expect(huile.matchesRef('huile'), isTrue);
    expect(
      categories
          .where((category) => category.id == 'boissons')
          .first
          .matchesProduct(categoryId: product.categoryId),
      isFalse,
    );
  });
}
