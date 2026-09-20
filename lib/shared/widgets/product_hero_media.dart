import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../theme/heyn_media.dart';
import '../models/product.dart';

class ProductHeroMedia extends StatelessWidget {
  const ProductHeroMedia({
    super.key,
    required this.product,
    this.size = 120,
    this.iconSize = 56,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.index,
  });

  final Product product;
  final double size;
  final double iconSize;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final url = product.imageUrl;
    Widget child;
    if (url != null && url.isNotEmpty) {
      child = Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) =>
            _Fallback(categoryId: product.categoryId, index: index),
      );
    } else {
      child = _Fallback(categoryId: product.categoryId, index: index);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: w.isFinite ? w : double.infinity,
        height: h.isFinite ? h : 88,
        child: child,
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.categoryId, this.index});

  final String categoryId;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final tone = ProductIconTone.forItem(categoryId: categoryId, index: index);
    return ColoredBox(
      color: tone.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          HeynPhoto(
            asset: HeynMedia.categoryPhoto(categoryId),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
