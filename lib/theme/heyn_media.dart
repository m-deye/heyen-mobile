import 'package:flutter/material.dart';

import 'heyn_colors.dart';

class HeynMedia {
  const HeynMedia._();

  static const cocktail = 'assets/images/categories/cocktail.png';
  static const homeBanner = 'assets/images/home_banner.png';
  static const bannerBasket = 'assets/images/categories/fruits.png';
  static const lait = 'assets/images/categories/lait.png';
  static const huile = 'assets/images/categories/huile.png';
  static const riz = 'assets/images/categories/riz.png';
  static const savon = 'assets/images/categories/savon.png';
  static const jus = 'assets/images/categories/jus.png';

  static String bannerPhotoAt(int index) {
    const photos = [
      homeBanner,
      'assets/images/categories/epicerie.png',
      'assets/images/categories/boissons.png',
    ];
    return photos[index % photos.length];
  }

  static String categoryPhoto(String categoryId) {
    return categoryPhotoOverride(categoryId) ??
        switch (categoryId) {
          'eau' => 'assets/images/categories/boissons.png',
          'dattes' => 'assets/images/categories/fruits.png',
          _ => 'assets/images/categories/boulangerie.png',
        };
  }

  static String? categoryPhotoOverride(String categoryId) {
    return switch (categoryId.trim().toLowerCase()) {
      'lait' || 'dairy' || 'fromage' || 'alban' || 'aliments-laitiers' => lait,
      'huile' || 'oils_ghee' || 'oil' => huile,
      'riz' || 'rice_grains' || 'arroz' => riz,
      'savon' || 'cleaning' || 'lessive' => savon,
      'jus' || 'boissons' => jus,
      _ => null,
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
