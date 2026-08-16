import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/device/device_service.dart';

const savedShowcaseIdsKey = 'zone_saved_showcase_ids';

/// Locally-tracked "saved" showcase project IDs for this device.
/// Independent of the Community module's backend bookmark count.
class SavedItemsPrefs {
  SavedItemsPrefs(this._prefs);

  final SharedPreferences _prefs;

  Set<String> getSavedIds() {
    return (_prefs.getStringList(savedShowcaseIdsKey) ?? const []).toSet();
  }

  bool isSaved(String id) {
    return getSavedIds().contains(id);
  }

  Future<void> toggleSaved(String id) async {
    final ids = getSavedIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await _prefs.setStringList(savedShowcaseIdsKey, ids.toList());
  }
}

final savedItemsPrefsProvider = Provider<SavedItemsPrefs>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SavedItemsPrefs(prefs);
});
