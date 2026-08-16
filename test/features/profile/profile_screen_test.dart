import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/profile/otp/otp_verify_screen.dart';
import 'package:zone/features/profile/profile_screen.dart';
import 'package:zone/features/profile/providers/theme_mode_provider.dart';

const _myHash = 'me1234567890abcd';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> pumpProfile(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();
    final mockClient = MockClient((req) async {
      if (req.url.path == '/pins') {
        return http.Response(
          jsonEncode([
            {'id': 'p1', 'authorHash': _myHash, 'upvotes': 4},
          ]),
          200,
        );
      } else if (req.url.path == '/posts') {
        return http.Response(
          jsonEncode([
            {'id': 'post1', 'authorHash': _myHash, 'upvotes': 6},
          ]),
          200,
        );
      } else if (req.url.path == '/community/questions') {
        return http.Response(jsonEncode([]), 200);
      }
      return http.Response('not found', 404);
    });

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        hashedDeviceIdProvider.overrideWith((ref) async => _myHash),
        apiClientProvider.overrideWith(
          (ref) async => ApiClient(hashedDeviceId: _myHash, httpClient: mockClient, baseUrl: 'http://test.local'),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    return container;
  }

  testWidgets('renders karma number after loading and settings rows', (tester) async {
    await pumpProfile(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('10'), findsOneWidget);
    expect(find.text('Karma'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Anonymous verification'), findsOneWidget);
    expect(find.text('ZONE v1.0.0'), findsOneWidget);
  });

  testWidgets('tapping the verification row navigates to OtpVerifyScreen', (tester) async {
    await pumpProfile(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('anonymousVerificationRow')));
    await tester.pumpAndSettle();

    expect(find.byType(OtpVerifyScreen), findsOneWidget);
    expect(find.byKey(const Key('phoneField')), findsOneWidget);
  });

  testWidgets('toggling the dark-mode switch updates themeModeProvider value', (tester) async {
    final container = await pumpProfile(tester);
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.system);

    await tester.tap(find.byKey(const Key('darkModeSwitch')));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
