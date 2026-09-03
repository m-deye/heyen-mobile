import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../models/category.dart';
import 'product_image_placeholder.dart';

/// Image catégorie : réseau si [Category.imageUrl], sinon placeholder.
class CategoryMedia extends StatelessWidget {
  const CategoryMedia({
    super.key,
    required this.category,
    this.height = 86,
  });

  final Category category;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = category.imageUrl;
    final radius = BorderRadius.circular(AppRadius.button);

    if (url == null || url.isEmpty) {
      return ProductImagePlaceholder(
        label: category.imageLabel,
        width: double.infinity,
        height: height,
        background: AppColors.productTile(category.id),
        showLabel: false,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.network(
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
