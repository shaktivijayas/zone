import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/features/profile/otp/otp_prefs.dart';
import 'package:zone/features/profile/otp/otp_verify_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpScreen(WidgetTester tester, SharedPreferences prefs) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: OtpVerifyScreen()),
      ),
    );
  }

  testWidgets('starts on the phone step with a Send code button', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await pumpScreen(tester, prefs);

    expect(find.byKey(const Key('phoneField')), findsOneWidget);
    expect(find.byKey(const Key('sendCodeButton')), findsOneWidget);
    expect(find.byKey(const Key('codeField')), findsNothing);
  });

  testWidgets('tapping Send code reveals the 6-digit code field', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await pumpScreen(tester, prefs);

    await tester.enterText(find.byKey(const Key('phoneField')), '5551234567');
    await tester.tap(find.byKey(const Key('sendCodeButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('codeField')), findsOneWidget);
    expect(find.byKey(const Key('verifyButton')), findsOneWidget);
  });

  testWidgets('a valid 6-digit code shows the success state and persists verified flag', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await pumpScreen(tester, prefs);

    await tester.tap(find.byKey(const Key('sendCodeButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('codeField')), '123456');
    await tester.tap(find.byKey(const Key('verifyButton')));
    await tester.pumpAndSettle();

    expect(find.text('Verified ✓'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(OtpPrefs(prefs).isVerified(), isTrue);
  });

  testWidgets('an invalid code shows an inline error and does not mark verified', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await pumpScreen(tester, prefs);

    await tester.tap(find.byKey(const Key('sendCodeButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('codeField')), '123');
    await tester.tap(find.byKey(const Key('verifyButton')));
    await tester.pumpAndSettle();

    expect(find.text('Must be exactly 6 digits'), findsOneWidget);
    expect(find.text('Verified ✓'), findsNothing);
    expect(OtpPrefs(prefs).isVerified(), isFalse);
  });
}
