import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'heyn_colors.dart';

class HeynTextStyles {
  const HeynTextStyles._();

  static TextStyle get displayTitle => GoogleFonts.playfairDisplay(
    fontSize: 27,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: HeynColors.navy,
  );

  static TextStyle get sectionTitle => GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: HeynColors.navy,
  );

  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: HeynColors.textMuted,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: HeynColors.navy,
  );

  static TextStyle get priceBold => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: HeynColors.navy,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: HeynColors.navy,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: HeynColors.textMuted,
  );
}
