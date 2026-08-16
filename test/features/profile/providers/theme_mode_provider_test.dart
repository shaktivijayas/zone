import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/features/profile/providers/theme_mode_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to ThemeMode.system when no pref is stored', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('toggleDarkMode(true) sets dark, toggleDarkMode(false) sets light', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await container.read(themeModeProvider.notifier).toggleDarkMode(true);
    expect(container.read(themeModeProvider), ThemeMode.dark);

    await container.read(themeModeProvider.notifier).toggleDarkMode(false);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('persists the choice across a fresh provider container backed by the same prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final container1 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    await container1.read(themeModeProvider.notifier).toggleDarkMode(true);
    container1.dispose();

    final container2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container2.dispose);

    expect(container2.read(themeModeProvider), ThemeMode.dark);
  });
}
