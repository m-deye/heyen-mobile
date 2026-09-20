import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../theme/heyn_media.dart';
import '../models/category.dart';
import 'product_image_placeholder.dart';

/// Image catégorie : asset local prioritaire, puis réseau si [Category.imageUrl].
class CategoryMedia extends StatelessWidget {
  const CategoryMedia({super.key, required this.category, this.height = 86});

  final Category category;
  final double height;
  static const _radius = 16.0;

  @override
  Widget build(BuildContext context) {
    final asset = HeynMedia.categoryPhotoOverride(category.id);
    final url = category.imageUrl;
    final radius = BorderRadius.circular(_radius);

    Widget rounded(Widget child) {
      return ClipRRect(borderRadius: radius, child: child);
    }

    if (asset != null) {
      return rounded(
        HeynPhoto(asset: asset, width: double.infinity, height: height),
      );
    }

    if (url == null || url.isEmpty) {
      return rounded(
        ProductImagePlaceholder(
          label: category.imageLabel,
          width: double.infinity,
          height: height,
          background: AppColors.productTile(category.id),
          showLabel: false,
        ),
      );
    }

    return rounded(
      Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return ProductImagePlaceholder(
            label: category.imageLabel,
            width: double.infinity,
            height: height,
            background: AppColors.productTile(category.id),
            showLabel: false,
          );
        },
      ),
    );
  }
}
