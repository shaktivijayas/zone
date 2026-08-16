import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/answer.dart';

class AnswerTile extends StatelessWidget {
  const AnswerTile({
    super.key,
    required this.answer,
    required this.isAccepted,
    this.canAccept = false,
    this.onAccept,
  });

  final Answer answer;
  final bool isAccepted;
  final bool canAccept;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAccepted ? AppColors.semanticChill : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(answer.text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(_relativeTime(answer.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_upward, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${answer.upvotes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              if (isAccepted)
                const Icon(Icons.check_circle, color: AppColors.semanticChill, size: 20)
              else if (canAccept)
                TextButton(
                  onPressed: onAccept,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.semanticChill,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
