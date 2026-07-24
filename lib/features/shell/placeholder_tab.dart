import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label — coming in the next slice',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
      ),
    );
  }
}
