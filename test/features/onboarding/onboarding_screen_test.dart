import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';
import 'package:zone/features/onboarding/onboarding_screen.dart';

void main() {
  Widget buildTestApp(SharedPreferences prefs) {
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
        GoRoute(path: '/home/map', builder: (context, state) => const Scaffold(body: Text('HOME'))),
      ],
    );
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('shows first slide heading initially', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(buildTestApp(prefs));
    await tester.pumpAndSettle();

    expect(find.textContaining('Your campus.'), findsOneWidget);
  });

  testWidgets('tapping Skip completes onboarding and navigates home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(buildTestApp(prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(OnboardingPrefs(prefs).isOnboardingComplete(), isTrue);
  });

  testWidgets('swiping through all slides and tapping Get Started navigates home', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(buildTestApp(prefs));
    await tester.pumpAndSettle();

    await tester.fling(find.textContaining('Your campus.'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(find.textContaining('Say what'), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });
}
