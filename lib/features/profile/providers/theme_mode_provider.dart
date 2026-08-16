import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/device/device_service.dart';

const themeModeKey = 'zone_theme_mode';

class ThemeModePrefs {
  ThemeModePrefs(this._prefs);

  final SharedPreferences _prefs;

  ThemeMode getThemeMode() {
    final value = _prefs.getString(themeModeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(themeModeKey, _modeToString(mode));
  }

  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeModePrefsProvider = Provider<ThemeModePrefs>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModePrefs(prefs);
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(themeModePrefsProvider).getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref.read(themeModePrefsProvider).setThemeMode(mode);
  }

  /// Flips between light and dark (system is treated as a starting point
  /// that toggling always resolves away from).
  Future<void> toggleDarkMode(bool enableDark) async {
    await setThemeMode(enableDark ? ThemeMode.dark : ThemeMode.light);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
