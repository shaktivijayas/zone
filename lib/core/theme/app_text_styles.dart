import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headingDisplay => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 34 / 28,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyRegular => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 21 / 15,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmallSecondary => GoogleFonts.inter(
        fontWeight: FontWeight.w400,
        fontSize: 13,
        height: 18 / 13,
        color: AppColors.textSecondary,
      );
}
