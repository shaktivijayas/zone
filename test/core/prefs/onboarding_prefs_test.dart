import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isOnboardingComplete defaults to false', () async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingPrefs = OnboardingPrefs(prefs);

    expect(onboardingPrefs.isOnboardingComplete(), isFalse);
  });

  test('setOnboardingComplete persists true', () async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingPrefs = OnboardingPrefs(prefs);

    await onboardingPrefs.setOnboardingComplete();

    expect(onboardingPrefs.isOnboardingComplete(), isTrue);
  });
}
