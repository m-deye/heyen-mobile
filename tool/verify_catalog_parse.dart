import 'dart:convert';
import 'dart:io';

import 'package:ecommerce_app/core/api/api_json.dart';
import 'package:ecommerce_app/shared/models/category.dart';
import 'package:ecommerce_app/shared/models/product.dart';

Future<Object?> fetchJson(String path) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(
      Uri.parse('https://heyen-gust.vercel.app$path'),
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    stdout.writeln('$path HTTP ${response.statusCode}');
    return jsonDecode(body);
  } finally {
    client.close(force: true);
  }
}

void main() async {
  final categoriesPayload = await fetchJson('/api/categories');
  final productsPayload = await fetchJson('/api/products?pageSize=50');

  final categories = [
    for (final json in unwrapApiList(categoriesPayload))
      Category(
        id: '${json['slug'] ?? json['id']}',
        apiId: '${json['id'] ?? ''}',
        label: '${json['name'] ?? json['label']}',
        description: '${json['description'] ?? ''}',
        imageLabel: 'Cat',
      ),
  ];
  final products = [
    for (final json in unwrapApiList(productsPayload)) Product.fromJson(json),
  ];

  final huile = categories.cast<Category?>().firstWhere(
    (category) =>
        category?.id == 'huile' || category?.matchesRef('huile') == true,
    orElse: () => null,
  );
  final matched = [
    for (final product in products)
      if (huile != null && product.belongsToCategory(huile)) product,
  ];

  stdout.writeln(
    'categories=${categories.map((c) => '${c.id}/${c.apiId}').join(', ')}',
  );
  stdout.writeln('products=${products.length}');
  for (final product in products) {
    stdout.writeln(
      'product name=${product.name} categoryId=${product.categoryId} '
      'categoryApiId=${product.categoryApiId}',
    );
  }
  stdout.writeln('huileMatched=${matched.length}');
  if (matched.isEmpty) {
    stderr.writeln('FAIL: no product would appear for category huile');
    exitCode = 1;
    return;
  }
  stdout.writeln('PASS: ${matched.first.name} would appear for category huile');
}
