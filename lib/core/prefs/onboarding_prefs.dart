import 'package:shared_preferences/shared_preferences.dart';

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
