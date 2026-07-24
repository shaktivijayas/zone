import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../device/device_service.dart';

const onboardingCompleteKey = 'zone_onboarding_complete';

class OnboardingPrefs {
  OnboardingPrefs(this._prefs);

  final SharedPreferences _prefs;

  bool isOnboardingComplete() {
    return _prefs.getBool(onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(onboardingCompleteKey, true);
  }
}

final onboardingPrefsProvider = Provider<OnboardingPrefs>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingPrefs(prefs);
});
