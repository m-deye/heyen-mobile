import 'package:flutter/material.dart';

import 'heyn_colors.dart';

class HeynMedia {
  const HeynMedia._();

  static const cocktail = 'assets/images/categories/cocktail.png';
  static const bannerBasket = 'assets/images/categories/fruits.png';

  static String bannerPhotoAt(int index) {
    const photos = [
      bannerBasket,
      'assets/images/categories/epicerie.png',
      'assets/images/categories/boissons.png',
    ];
    return photos[index % photos.length];
  }

  static String categoryPhoto(String categoryId) {
    return switch (categoryId) {
      'jus' || 'eau' => 'assets/images/categories/boissons.png',
      'dattes' => 'assets/images/categories/fruits.png',
      'riz' || 'huile' => 'assets/images/categories/epicerie.png',
      _ => 'assets/images/categories/boulangerie.png',
    };
  }

  static List<Color> footerWash(String categoryId) {
    return switch (categoryId) {
      'jus' || 'eau' => const [Color(0xFFD4EAF3), Color(0xFFB9D8E8)],
      'dattes' => const [Color(0xFFD8F0C4), Color(0xFFC5E4A8)],
      'riz' || 'huile' => const [Color(0xFFF3D6E4), Color(0xFFE8C0D2)],
      _ => const [Color(0xFFD6EEF0), Color(0xFFB8DDE0)],
    };
  }

  static Color titleColor(String categoryId) {
    return HeynColors.navy;
  }
}

class HeynPhoto extends StatelessWidget {
  const HeynPhoto({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => ColoredBox(
        color: const Color(0xFFF0E6D0),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: HeynColors.turquoise.withValues(alpha: 0.7),
            size: 28,
          ),
        ),
      ),
    );
  }
}
