import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingProgressPill extends StatelessWidget {
  const OnboardingProgressPill({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Container(
            width: 24,
            height: 4,
            decoration: BoxDecoration(
              color: i == activeIndex ? AppColors.ctaBlack : AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }
}
