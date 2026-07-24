import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ShowcaseMockCard extends StatelessWidget {
  const ShowcaseMockCard({super.key});

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
                height: 140,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF312E81)],
                  ),
                ),
              ),
              const Positioned(
                right: 10,
                top: 10,
                child: Icon(Icons.bookmark_border, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Campus Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: const [
                    _TechChip('Flutter'),
                    _TechChip('Firebase'),
                    _TechChip('Groq'),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    CircleAvatar(radius: 8, backgroundColor: AppColors.cardBorder),
                    SizedBox(width: 6),
                    Text('Anonymous', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
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
