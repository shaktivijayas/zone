import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'providers/karma_provider.dart';
import 'widgets/saved_items_list.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karmaAsync = ref.watch(karmaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  karmaAsync.when(
                    data: (karma) => Text(
                      '$karma',
                      style: AppTextStyles.headingDisplay.copyWith(fontSize: 40),
                    ),
                    loading: () => const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    error: (err, stack) => Text(
                      '--',
                      style: AppTextStyles.headingDisplay.copyWith(fontSize: 40, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Karma', style: AppTextStyles.bodySmallSecondary),
                ],
              ),
            ),
          ),
          const SavedItemsList(),
          const SettingsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
