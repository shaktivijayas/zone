import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.ctaBlack,
      onPrimary: Colors.white,
      secondary: AppColors.textSecondary,
      onSecondary: Colors.white,
      error: AppColors.semanticAlert,
      onError: Colors.white,
      surface: AppColors.cardFill,
      onSurface: AppColors.textPrimary,
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,
      dividerColor: AppColors.cardBorder,
    );
  }
}
