import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/device/device_service.dart';

const otpVerifiedKey = 'zone_otp_verified';

class OtpPrefs {
  OtpPrefs(this._prefs);

  final SharedPreferences _prefs;

  bool isVerified() {
    return _prefs.getBool(otpVerifiedKey) ?? false;
  }

  Future<void> setVerified() async {
    await _prefs.setBool(otpVerifiedKey, true);
  }
}

final otpPrefsProvider = Provider<OtpPrefs>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OtpPrefs(prefs);
});
