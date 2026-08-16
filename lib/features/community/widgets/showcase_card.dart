import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/showcase_project.dart';

class ShowcaseCard extends StatelessWidget {
  const ShowcaseCard({super.key, required this.project, this.onBookmark});

  final ShowcaseProject project;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: project.imageUrl != null && project.imageUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(project.imageUrl!), fit: BoxFit.cover)
                      : null,
                  gradient: project.imageUrl == null || project.imageUrl!.isEmpty
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6366F1), Color(0xFF312E81)],
                        )
                      : null,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                if (project.techStack.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (final tech in project.techStack) _TechChip(tech)],
                  ),
                ],
                const SizedBox(height: 10),
                InkWell(
                  onTap: onBookmark,
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_border, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${project.bookmarkCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
    );
  }
}
