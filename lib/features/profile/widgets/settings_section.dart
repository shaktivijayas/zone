import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../otp/otp_prefs.dart';
import '../otp/otp_verify_screen.dart';
import '../providers/theme_mode_provider.dart';

class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isVerified = ref.watch(otpPrefsProvider).isVerified();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: AppColors.cardFill,
              child: Column(
                children: [
                  ListTile(
                    title: Text('Dark mode', style: AppTextStyles.bodyRegular),
                    trailing: Switch(
                      key: const Key('darkModeSwitch'),
                      value: themeMode == ThemeMode.dark,
                      onChanged: (enableDark) {
                        ref.read(themeModeProvider.notifier).toggleDarkMode(enableDark);
                      },
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  ListTile(
                    key: const Key('anonymousVerificationRow'),
                    title: Text('Anonymous verification', style: AppTextStyles.bodyRegular),
                    trailing: Text(
                      isVerified ? 'Verified ✓' : 'Not verified',
                      style: TextStyle(
                        color: isVerified ? AppColors.semanticChill : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const OtpVerifyScreen()),
                      );
                      if (context.mounted) {
                        ref.invalidate(otpPrefsProvider);
                      }
                    },
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  ListTile(
                    title: Text('App version', style: AppTextStyles.bodyRegular),
                    trailing: Text('ZONE v1.0.0', style: AppTextStyles.bodySmallSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
