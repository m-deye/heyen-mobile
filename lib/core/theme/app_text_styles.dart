import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get display => GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.textPrimary,
  );

  static TextStyle get title => GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline => GoogleFonts.playfairDisplay(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static TextStyle get price => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextTheme textTheme() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displaySmall: display,
      headlineMedium: headline,
      headlineSmall: title,
      titleLarge: title.copyWith(fontSize: 20),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      bodyLarge: body.copyWith(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: label.copyWith(fontSize: 14),
      labelMedium: label,
      labelSmall: caption.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
