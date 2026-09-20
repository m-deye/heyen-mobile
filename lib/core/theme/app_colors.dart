import 'package:flutter/material.dart';

import '../../theme/heyn_colors.dart';

/// Palette officielle Heyn issue des références visuelles.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF087786);
  static const Color primaryDark = Color(0xFF05606C);
  static const Color primaryPressed = Color(0xFF064E58);

  static const Color darkText = Color(0xFF102D33);
  static const Color secondaryText = Color(0xFF8FA3A8);
  static const Color mutedText = Color(0xFFAEBEC2);

  static const Color background = Color(0xFFFFFFFF);
  static const surface = HeynColors.creamCard;
  static const surfaceMuted = Color(0xFFE8EEF2);
  static const Color scaffoldBackground = Color(0xFFF5F9F9);
  static const Color lightTeal = Color(0xFFEDF7F7);
  static const Color hatchGreen = Color(0xFFE4EFEC);

  static const Color success = Color(0xFF1FA85B);
  static const Color successBackground = Color(0xFFE7F6EE);
  static const Color warning = Color(0xFFF5A623);
  static const Color warningBackground = Color(0xFFFDF1DC);
  static const Color danger = Color(0xFFE23D3D);
  static const Color dangerBackground = Color(0xFFFBE7E7);

  static const Color cartBadge = Color(0xFFF5920B);
  static const Color darkButton = Color(0xFF102D33);
  static const Color rating = Color(0xFFF5A623);

  static const Color border = Color(0xFFE6EEEE);
  static const Color divider = Color(0xFFEEF3F3);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color chipBackground = Color(0xFFFFFFFF);
  static const Color chipSelectedBackground = Color(0xFFEDF7F7);
  static const Color shimmerBase = Color(0xFFECF1F1);
  static const Color shimmerHighlight = Color(0xFFF7FAFA);
  static const List<Color> categoryTints = <Color>[
    Color(0xFFEAF3F1),
    Color(0xFFF6EFE2),
    Color(0xFFECEFF4),
    Color(0xFFF3EEE9),
    Color(0xFFEFF4EC),
    Color(0xFFEDEFF3),
  ];
  static const Color shadow = Color(0x14102D33);

  static const primaryLight = HeynColors.turquoise;
  static const accent = HeynColors.turquoise;
  static const gold = HeynColors.turquoise;
  static const textPrimary = HeynColors.textDark;
  static const textSecondary = HeynColors.textMuted;
  static const textMuted = HeynColors.textMuted;

  static const accentOrange = danger;
  static const successBg = successBackground;
  static const successText = Color(0xFF2E7D32);
  static const dangerBg = dangerBackground;
  static const chipIdle = HeynColors.creamCard;
  static const iconCircle = HeynColors.cream;
  static const inputBorder = border;
  static const metal = HeynColors.silverStart;
  static const bannerOn = HeynColors.navy;

  static const headerGradient = HeynColors.buttonGradient;

  static const buttonGradient = HeynColors.buttonGradient;

  static const logoGradient = HeynColors.buttonGradient;

  static const cardShadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  static List<BoxShadow> get primaryButtonShadow => const [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static Color productTile(String categoryId) =>
      ProductIconTone.forCategory(categoryId).background;

  static ChipPalette chipPaletteFor(String? id) {
    if (id == null || id == 'tout') {
      return ChipPalette.selected;
    }
    return ChipPalette.fromTone(ProductIconTone.forCategory(id));
  }

  static ChipPalette chipPaletteAt(int index) {
    return ChipPalette.fromTone(ProductIconTone.at(index));
  }
}

class ProductIconTone {
  const ProductIconTone({
    required this.background,
    required this.icon,
    required this.name,
  });

  final Color background;
  final Color icon;
  final String name;

  static const rose = ProductIconTone(
    background: Color(0xFFFCE4EC),
    icon: Color(0xFFD81B60),
    name: 'rose',
  );
  static const turquoise = ProductIconTone(
    background: Color(0xFFE0F2F1),
    icon: Color(0xFF00897B),
    name: 'turquoise',
  );
  static const amber = ProductIconTone(
    background: Color(0xFFFFF3E0),
    icon: Color(0xFFEF6C00),
    name: 'amber',
  );
  static const green = ProductIconTone(
    background: Color(0xFFE8F5E9),
    icon: Color(0xFF2E7D32),
    name: 'green',
  );

  static const all = [rose, turquoise, amber, green];

  static ProductIconTone at(int index) => all[index % all.length];

  static ProductIconTone forCategory(String categoryId) {
    return switch (categoryId) {
      'jus' => rose,
      'eau' => turquoise,
      'huile' || 'riz' => amber,
      'dattes' => green,
      'savon' || 'lessive' => rose,
      _ => amber,
    };
  }

  static ProductIconTone forItem({required String categoryId, int? index}) {
    if (index != null) {
      return at(index);
    }
    return forCategory(categoryId);
  }

  static IconData iconFor(String categoryId) {
    return switch (categoryId) {
      'jus' => Icons.local_bar_outlined,
      'eau' => Icons.water_drop_outlined,
      'dattes' => Icons.spa_outlined,
      'huile' => Icons.opacity_outlined,
      'savon' => Icons.soap_outlined,
      'lessive' => Icons.local_laundry_service_outlined,
      'riz' => Icons.rice_bowl_outlined,
      _ => Icons.shopping_bag_outlined,
    };
  }
}

class ChipPalette {
  const ChipPalette({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  factory ChipPalette.fromTone(ProductIconTone tone) {
    return ChipPalette(background: tone.background, foreground: tone.icon);
  }

  static const selected = ChipPalette(
    background: HeynColors.navy,
    foreground: Color(0xFFFFFFFF),
  );
  static const teal = ChipPalette(
    background: Color(0xFFE0F2F1),
    foreground: Color(0xFF00897B),
  );
  static const coral = ChipPalette(
    background: Color(0xFFFCE4EC),
    foreground: Color(0xFFD81B60),
  );
  static const lavender = ChipPalette(
    background: Color(0xFFFFF3E0),
    foreground: Color(0xFFEF6C00),
  );
  static const gold = ChipPalette(
    background: Color(0xFFE8F5E9),
    foreground: Color(0xFF2E7D32),
  );
  static const success = ChipPalette(
    background: AppColors.successBg,
    foreground: AppColors.successText,
  );
  static const warning = ChipPalette(
    background: AppColors.dangerBg,
    foreground: Color(0xFFC2185B),
  );
  static const muted = ChipPalette(
    background: AppColors.surfaceMuted,
    foreground: AppColors.textSecondary,
  );
  static const bannerChip = ChipPalette(
    background: Color(0xFF4A3728),
    foreground: Color(0xFFFFF8E7),
  );
}

class AppSpacing {
  const AppSpacing._();

  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
}

class AppRadius {
  const AppRadius._();

  static const card = 18.0;
  static const button = 999.0;
  static const sheet = 24.0;
  static const pill = 999.0;
}
