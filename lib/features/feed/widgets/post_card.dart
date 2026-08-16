import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/post.dart';
import '../utils/flair.dart';
import '../utils/relative_time.dart';

/// The real feed post card, matching the visual style of
/// `FeedPostMockCard` but wired to live data and callbacks.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onTap, required this.onUpvote});

  final Post post;
  final VoidCallback onTap;
  final VoidCallback onUpvote;

  @override
  Widget build(BuildContext context) {
    final flair = flairInfoFor(post.flair);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: flair.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${flair.emoji} ${post.flair}',
                    style: TextStyle(fontSize: 12, color: flair.color, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  relativeTime(post.createdAtTime),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(post.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: onUpvote,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${post.upvotes}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${post.commentCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                const Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
