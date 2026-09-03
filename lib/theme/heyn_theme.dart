import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'heyn_colors.dart';
import 'heyn_text_styles.dart';

export 'heyn_atmosphere.dart';
export 'heyn_colors.dart';
export 'heyn_media.dart';
export 'heyn_text_styles.dart';
export 'heyn_widgets.dart';

class HeynTheme {
  const HeynTheme._();

  static ThemeData light() {
    final inter = GoogleFonts.interTextTheme();
    const scheme = ColorScheme.light(
      primary: HeynColors.navy,
      secondary: HeynColors.turquoise,
      surface: HeynColors.cream,
      error: HeynColors.danger,
      onPrimary: HeynColors.onNavy,
      onSecondary: Colors.white,
      onSurface: HeynColors.textDark,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: HeynColors.pageMint,
      canvasColor: HeynColors.cream,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: inter.copyWith(
        displaySmall: HeynTextStyles.displayTitle,
        headlineMedium: HeynTextStyles.displayTitle,
        headlineSmall: HeynTextStyles.sectionTitle,
        titleLarge: HeynTextStyles.sectionTitle,
        titleMedium: HeynTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: HeynTextStyles.bodyMedium,
        bodyMedium: HeynTextStyles.subtitle.copyWith(
          color: HeynColors.textDark,
        ),
        bodySmall: HeynTextStyles.subtitle,
        labelLarge: HeynTextStyles.button,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: HeynColors.textDark,
        backgroundColor: HeynColors.cream,
        titleTextStyle: HeynTextStyles.sectionTitle,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: HeynColors.creamCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: HeynColors.borderGold),
        ),
      ),
      dividerColor: HeynColors.borderGold.withValues(alpha: 0.45),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: HeynColors.cream,
        selectedItemColor: HeynColors.navy,
        unselectedItemColor: HeynColors.inactiveGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: HeynColors.navy,
          foregroundColor: HeynColors.onNavy,
          textStyle: HeynTextStyles.button,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HeynColors.navy,
          side: const BorderSide(color: HeynColors.turquoise),
          backgroundColor: HeynColors.creamCard,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: HeynTextStyles.button,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: HeynColors.navy,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: HeynColors.creamCard,
        titleTextStyle: HeynTextStyles.sectionTitle,
        contentTextStyle: HeynTextStyles.subtitle.copyWith(
          color: HeynColors.textDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HeynColors.creamCard,
        modalBackgroundColor: HeynColors.creamCard,
      ),
    );
  }
}
