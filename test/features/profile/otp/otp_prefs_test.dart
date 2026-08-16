import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/features/profile/otp/otp_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isVerified defaults to false', () async {
    final prefs = await SharedPreferences.getInstance();
    final otpPrefs = OtpPrefs(prefs);

    expect(otpPrefs.isVerified(), isFalse);
  });

  test('setVerified persists true', () async {
    final prefs = await SharedPreferences.getInstance();
    final otpPrefs = OtpPrefs(prefs);

    await otpPrefs.setVerified();

    expect(otpPrefs.isVerified(), isTrue);
  });

  test('round-trips across instances backed by the same prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = OtpPrefs(prefs);
    await first.setVerified();

    final second = OtpPrefs(prefs);
    expect(second.isVerified(), isTrue);
  });
}
