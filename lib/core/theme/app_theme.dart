import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/heyn_theme.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => HeynTheme.light();

  static ThemeData premium() {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.background,
      error: AppColors.danger,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: AppTextStyles.textTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        backgroundColor: AppColors.background,
        titleTextStyle: AppTextStyles.title.copyWith(fontSize: 18),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      dividerColor: AppColors.divider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(Colors.transparent),
        focusedBorder: _inputBorder(AppColors.primary, width: 1.4),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.4),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppTextStyles.label,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTextStyles.button,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: AppTextStyles.label,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: AppTextStyles.title.copyWith(fontSize: 20),
        contentTextStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primaryDark,
        textColor: AppColors.textPrimary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
