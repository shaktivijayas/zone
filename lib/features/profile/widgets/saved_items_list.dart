import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../prefs/saved_items_prefs.dart';

/// Shows the locally-saved showcase project IDs for this device.
/// This is a simple slice: no join with real showcase data yet, just the
/// raw saved IDs with a remove action.
class SavedItemsList extends ConsumerWidget {
  const SavedItemsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedItemsPrefs = ref.watch(savedItemsPrefsProvider);
    final savedIds = savedItemsPrefs.getSavedIds().toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saved (${savedIds.length})', style: AppTextStyles.bodyRegular.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (savedIds.isEmpty)
            Text('No saved items yet', style: AppTextStyles.bodySmallSecondary)
          else
            ...savedIds.map(
              (id) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardFill,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(id, style: AppTextStyles.bodyRegular),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark, color: AppColors.ctaBlack),
                    tooltip: 'Remove',
                    onPressed: () async {
                      await savedItemsPrefs.toggleSaved(id);
                      ref.invalidate(savedItemsPrefsProvider);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
