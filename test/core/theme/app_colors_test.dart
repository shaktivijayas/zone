import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zone/core/theme/app_colors.dart';

void main() {
  test('token values match the design spec', () {
    expect(AppColors.background, const Color(0xFFFAFAFA));
    expect(AppColors.textPrimary, const Color(0xFF111111));
    expect(AppColors.textSecondary, const Color(0xFF6B7280));
    expect(AppColors.cardBorder, const Color(0xFFE5E7EB));
    expect(AppColors.cardFill, const Color(0xFFFFFFFF));
    expect(AppColors.ctaBlack, const Color(0xFF111111));
    expect(AppColors.semanticAlert, const Color(0xFFDC2626));
    expect(AppColors.semanticHot, const Color(0xFFEA580C));
    expect(AppColors.semanticInfo, const Color(0xFFD97706));
    expect(AppColors.semanticChill, const Color(0xFF16A34A));
    expect(AppColors.navActive, const Color(0xFF111111));
    expect(AppColors.navInactive, const Color(0xFF9CA3AF));
  });
}
