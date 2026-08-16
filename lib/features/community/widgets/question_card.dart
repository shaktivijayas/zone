import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/question.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({super.key, required this.question, this.onTap});

  final Question question;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final answered = question.acceptedAnswerId != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                if (answered) ...[
                  const SizedBox(width: 8),
                  const _AnsweredBadge(),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              question.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.arrow_upward, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${question.upvotes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${question.answerCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnsweredBadge extends StatelessWidget {
  const _AnsweredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.semanticChill.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, size: 14, color: AppColors.semanticChill),
          SizedBox(width: 4),
          Text('Answered', style: TextStyle(fontSize: 11, color: AppColors.semanticChill, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
