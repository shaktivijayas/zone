import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/prefs/onboarding_prefs.dart';
import 'package:zone/features/splash/splash_screen.dart';

void main() {
  Widget buildTestApp() {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/onboarding', builder: (context, state) => const Scaffold(body: Text('ONBOARDING'))),
        GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('HOME'))),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('navigates to onboarding when onboarding not complete', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(buildTestApp());

    expect(find.text('ZONE'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('navigates to home when onboarding already complete', (tester) async {
    SharedPreferences.setMockInitialValues({onboardingCompleteKey: true});
    await tester.pumpWidget(buildTestApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });
}
