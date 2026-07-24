import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';
import 'package:zone/features/splash/splash_screen.dart';

void main() {
  Widget buildTestApp(SharedPreferences prefs) {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const Scaffold(body: Text('ONBOARDING'))),
        GoRoute(path: '/home/map', builder: (context, state) => const Scaffold(body: Text('HOME'))),
      ],
    );
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('navigates to onboarding when onboarding not complete', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(buildTestApp(prefs));

    expect(find.text('ZONE'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('ZONE'), findsOneWidget);
    expect(find.text('ONBOARDING'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('navigates to home when onboarding already complete', (tester) async {
    SharedPreferences.setMockInitialValues({onboardingCompleteKey: true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(buildTestApp(prefs));

    await tester.pump(const Duration(milliseconds: 1900));
    expect(find.text('HOME'), findsNothing);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });
}
