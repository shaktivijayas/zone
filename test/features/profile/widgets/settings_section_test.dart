import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/features/profile/otp/otp_verify_screen.dart';
import 'package:zone/features/profile/providers/theme_mode_provider.dart';
import 'package:zone/features/profile/widgets/settings_section.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpSettings(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: SettingsSection())),
      ),
    );
    return container;
  }

  testWidgets('renders dark mode row, verification row, and version row', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Anonymous verification'), findsOneWidget);
    expect(find.text('Not verified'), findsOneWidget);
    expect(find.text('ZONE v1.0.0'), findsOneWidget);
  });

  testWidgets('toggling dark mode switch updates themeModeProvider', (tester) async {
    final container = await pumpSettings(tester);

    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('tapping the verification row navigates to OtpVerifyScreen', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.byKey(const Key('anonymousVerificationRow')));
    await tester.pumpAndSettle();

    expect(find.byType(OtpVerifyScreen), findsOneWidget);
    expect(find.byKey(const Key('phoneField')), findsOneWidget);
  });
}
