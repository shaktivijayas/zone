import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FeedPostMockCard extends StatelessWidget {
  const FeedPostMockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.semanticAlert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🚨 Alert',
                  style: TextStyle(fontSize: 12, color: AppColors.semanticAlert, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              const Text('2 min ago', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Staff near C Block',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Faculty checking IDs.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.arrow_upward, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text('42', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text('18', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Spacer(),
              Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
