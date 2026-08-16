import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class FlairInfo {
  const FlairInfo(this.emoji, this.color);

  final String emoji;
  final Color color;
}

/// Maps each backend flair value to its display emoji and semantic color.
const flairOptions = <String, FlairInfo>{
  'Alert': FlairInfo('🚨', AppColors.semanticAlert),
  'Hot': FlairInfo('🔥', AppColors.semanticHot),
  'Info': FlairInfo('ℹ️', AppColors.semanticInfo),
  'Chill': FlairInfo('🧊', AppColors.semanticChill),
};

FlairInfo flairInfoFor(String flair) => flairOptions[flair] ?? flairOptions['Info']!;
