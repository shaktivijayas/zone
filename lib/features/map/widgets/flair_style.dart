import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// The four server-recognized pin flairs, in display order.
const List<String> kPinFlairs = ['Alert', 'Hot', 'Info', 'Chill'];

/// Semantic color for a given flair string, falling back to
/// [AppColors.textSecondary] for anything unrecognized.
Color flairColor(String flair) {
  switch (flair) {
    case 'Alert':
      return AppColors.semanticAlert;
    case 'Hot':
      return AppColors.semanticHot;
    case 'Info':
      return AppColors.semanticInfo;
    case 'Chill':
      return AppColors.semanticChill;
    default:
      return AppColors.textSecondary;
  }
}

/// Decorative emoji prefix for a given flair string.
String flairEmoji(String flair) {
  switch (flair) {
    case 'Alert':
      return '🚨';
    case 'Hot':
      return '🔥';
    case 'Info':
      return 'ℹ️';
    case 'Chill':
      return '❄️';
    default:
      return '📍';
  }
}
