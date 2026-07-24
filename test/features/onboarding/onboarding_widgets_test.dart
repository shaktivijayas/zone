import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/onboarding/widgets/onboarding_progress_pill.dart';
import 'package:zone/features/onboarding/widgets/map_pin_mock_card.dart';
import 'package:zone/features/onboarding/widgets/feed_post_mock_card.dart';
import 'package:zone/features/onboarding/widgets/showcase_mock_card.dart';

void main() {
  testWidgets('OnboardingProgressPill renders one segment per count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: OnboardingProgressPill(count: 3, activeIndex: 1)),
      ),
    );

    expect(find.byType(Container), findsNWidgets(3));
  });

  testWidgets('MapPinMockCard shows the pin label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MapPinMockCard())),
    );

    expect(find.textContaining('Library AC working today'), findsOneWidget);
  });

  testWidgets('FeedPostMockCard shows title, counts, and flair', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FeedPostMockCard())),
    );

    expect(find.text('Staff near C Block'), findsOneWidget);
    expect(find.textContaining('Alert'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
  });

  testWidgets('ShowcaseMockCard shows project name and tech chips', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ShowcaseMockCard())),
    );

    expect(find.text('Campus Dashboard'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Firebase'), findsOneWidget);
    expect(find.text('Groq'), findsOneWidget);
  });
}
