import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../../../core/api/api_json.dart';
import '../../../core/api/api_unreachable.dart';
import '../../../core/dev/dev_seed_data.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  final config = ref.watch(apiConfigProvider);
  if (!config.isConfigured) {
    return const DevCatalogRepository();
  }

  return ApiCatalogRepository(ref.watch(dioProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(catalogRepositoryProvider).getCategories();
});

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(catalogRepositoryProvider).getProducts();
});

final productProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  final decoded = Uri.decodeComponent(id);
  final products = await ref.watch(productsProvider.future);
  for (final product in products) {
    if (product.id == decoded || product.apiId == decoded) {
      return product;
    }
  }
  return ref.watch(catalogRepositoryProvider).getProductById(decoded);
});

abstract class CatalogRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
}

class ApiCatalogRepository implements CatalogRepository {
  const ApiCatalogRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get<Object?>(ApiEndpoints.categories);
      return unwrapApiList(response.data).map(_categoryFromJson).toList();
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return DevSeedData.categories;
      }
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get<Object?>(
        ApiEndpoints.products,
        queryParameters: const {'pageSize': 100},
      );
      return unwrapApiList(response.data).map(_productFromJson).toList();
    } on DioException catch (error) {
      if (isApiUnreachable(error)) {
        return const DevCatalogRepository().getProducts();
      }
      rethrow;
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    final decoded = Uri.decodeComponent(id);
    try {
      final response = await _dio.get<Object?>(
        '${ApiEndpoints.products}/$decoded',
      );
      final data = asJsonMap(unwrapApiData(response.data));
      if (data.isEmpty) {
        return const DevCatalogRepository().getProductById(decoded);
      }
      return _productFromJson(data);
    } on DioException catch (error) {
      if (isApiUnreachable(error) || error.response?.statusCode == 404) {
        return const DevCatalogRepository().getProductById(decoded);
      }
      rethrow;
    }
  }

  Category _categoryFromJson(Map<String, Object?> json) {
    final label = _readString(json, ['label', 'name']);
    return Category(
      id: _readString(json, ['slug', 'id']),
      label: label,
      description: _readString(json, ['description']),
      imageLabel: () {
        final tagged = _readString(json, ['image_label', 'imageLabel', 'slug']);
        if (tagged.isNotEmpty) {
          return tagged;
        }
        return label.length <= 3 ? label : label.substring(0, 3);
      }(),
      imageUrl: () {
        final url = _readString(json, ['imageUrl', 'image_url', 'image']);
        return url.isEmpty ? null : url;
      }(),
    );
  }

  Product _productFromJson(Map<String, Object?> json) {
    final mapped = Map<String, Object?>.from(json);
    final name = _readString(mapped, ['name', 'title']);
    final description = _readString(mapped, ['description']);
    final stock = _readInt(mapped, ['stock']);
    mapped['stock'] = stock;
    var status = _readString(mapped, ['status']);
    if (status.isEmpty) {
      status = stock <= 0
          ? 'Rupture'
          : stock <= 10
          ? 'Stock limité'
          : 'Disponible';
    }
    mapped['status'] = status;
    var imageLabel = _readString(mapped, ['image_label', 'imageLabel']);
    if (imageLabel.isEmpty && name.isNotEmpty) {
      imageLabel = name.length <= 3 ? name : name.substring(0, 3);
    }
    mapped['image_label'] = imageLabel;
    if (_readString(mapped, ['details']).isEmpty) {
      mapped['details'] = description;
    }
    return Product.fromJson(mapped);
  }

  String _readString(Map<String, Object?> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null) {
        return value.toString();
      }
    }

    return '';
  }

  int _readInt(Map<String, Object?> json, List<String> keys) {
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

class DevCatalogRepository implements CatalogRepository {
  const DevCatalogRepository();

  @override
  Future<List<Category>> getCategories() async => DevSeedData.categories;

  @override
  Future<Product?> getProductById(String id) async {
    for (final product in await getProducts()) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  @override
  Future<List<Product>> getProducts() async {
    return [
      for (final product in DevSeedData.products)
        DevSeedData.withStock(product),
    ];
  }
}
