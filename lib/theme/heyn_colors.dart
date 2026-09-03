import 'package:flutter/material.dart';

/// Charte officielle Heyn — navy (logo, titres, boutons) et turquoise (accents).
class HeynColors {
  const HeynColors._();

  static const navy = Color(0xFF0B2D5C);
  static const navyDark = Color(0xFF071C3A);
  static const turquoise = Color(0xFF1AA8B0);
  static const onNavy = Color(0xFFFFFFFF);

  /// Alias conservés pour le code existant — plus d'or / violet nuit.
  static const goldLight = turquoise;
  static const goldDark = turquoise;
  static const nightPurple = navy;
  static const nightPurpleDark = navyDark;
  static const nightPurpleLight = Color(0xFF7EC8CE);

  static const cream = Color(0xFFF7FAFC);
  static const creamCard = Color(0xFFFFFFFF);
  static const silverStart = Color(0xFFE8EEF2);
  static const silverEnd = Color(0xFFC5D0D6);
  static const textDark = Color(0xFF12233F);
  static const textMuted = Color(0xFF5A6B7A);
  static const borderGold = Color(0xFFB7D0D6);
  static const inactiveGrey = Color(0xFF8A97A3);
  static const danger = Color(0xFFC45C5C);

  static const pastelTurquoise = Color(0xFF7EC8CE);
  static const pastelRose = Color(0xFFB7D0D6);
  static const pastelBlue = Color(0xFF8BB4E0);
  static const pastelGold = Color(0xFF7EC8CE);
  static const pastelGreen = Color(0xFF8FBF7A);

  static const pageMint = Color(0xFFE8F3F4);
  static const pageLavender = Color(0xFFE4ECF5);
  static const pageGold = Color(0xFFF7FAFC);
  static const pageRose = Color(0xFFEAF6F7);

  static const goldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [navy, turquoise],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [navy, turquoise],
  );

  static const nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navy, navyDark],
  );

  static const silverGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [silverStart, silverEnd],
  );

  static const pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pageMint, pageLavender, pageGold, pageRose],
    stops: [0, 0.32, 0.68, 1],
  );

  static const cardShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static Color pastelBorderAt(int index) {
    const borders = [pastelTurquoise, pastelBlue, pastelRose, navy];
    return borders[index % borders.length].withValues(alpha: 0.45);
  }

  static List<Color> categoryWashFor(String id) {
    return switch (id) {
      'jus' || 'eau' => const [Color(0xFFD4EAF3), Color(0xFFB9D8E8)],
      'dattes' => const [Color(0xFFD8EDC6), Color(0xFFC5E4A8)],
      'riz' || 'huile' => const [Color(0xFFD6E4F0), Color(0xFFB7C9DC)],
      _ => const [Color(0xFFD6EEF0), Color(0xFFB8DDE0)],
    };
  }

  static List<Color> categoryWashAt(int index) {
    const washes = [
      [Color(0xFFD4EAF3), Color(0xFFB9D8E8)],
      [Color(0xFFD6EEF0), Color(0xFFB8DDE0)],
      [Color(0xFFD8EDC6), Color(0xFFC5E4A8)],
      [Color(0xFFD6E4F0), Color(0xFFB7C9DC)],
    ];
    return washes[index % washes.length];
  }
}
