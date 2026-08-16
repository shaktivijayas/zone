import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/community/community_screen.dart';

void main() {
  ApiClient buildClient({
    List<Map<String, dynamic>> questions = const [],
    List<Map<String, dynamic>> showcase = const [],
  }) {
    return ApiClient(
      hashedDeviceId: 'device1',
      baseUrl: 'http://test.local',
      httpClient: MockClient((req) async {
        if (req.url.path == '/community/questions') {
          return http.Response(jsonEncode(questions), 200);
        }
        if (req.url.path == '/community/showcase') {
          return http.Response(jsonEncode(showcase), 200);
        }
        return http.Response('{}', 404);
      }),
    );
  }

  Widget buildTestApp(ApiClient client) {
    return ProviderScope(
      overrides: [apiClientProvider.overrideWith((ref) async => client)],
      child: const MaterialApp(home: CommunityScreen()),
    );
  }

  testWidgets('shows questions in Ask & Answer tab and switches to Showcase tab', (tester) async {
    final client = buildClient(
      questions: [
        {
          'id': 'q1',
          'title': 'How do I join clubs?',
          'body': 'Need info',
          'createdAt': 1000,
          'upvotes': 3,
          'answerCount': 1,
          'acceptedAnswerId': null,
          'authorHash': 'h1',
        },
      ],
      showcase: [
        {
          'id': 's1',
          'title': 'Campus Dashboard',
          'description': 'A cool app',
          'techStack': ['Flutter'],
          'imageUrl': null,
          'createdAt': 1000,
          'bookmarkCount': 2,
          'authorHash': 'h1',
        },
      ],
    );

    await tester.pumpWidget(buildTestApp(client));
    await tester.pumpAndSettle();

    expect(find.text('How do I join clubs?'), findsOneWidget);
    expect(find.text('Campus Dashboard'), findsNothing);

    await tester.tap(find.text('Showcase'));
    await tester.pumpAndSettle();

    expect(find.text('Campus Dashboard'), findsOneWidget);
    expect(find.text('How do I join clubs?'), findsNothing);
  });

  testWidgets('shows empty states when there is no data', (tester) async {
    final client = buildClient();

    await tester.pumpWidget(buildTestApp(client));
    await tester.pumpAndSettle();

    expect(find.text('No questions yet — ask the first one'), findsOneWidget);

    await tester.tap(find.text('Showcase'));
    await tester.pumpAndSettle();

    expect(find.text('No projects yet — show off your work'), findsOneWidget);
  });

  testWidgets('FAB on Ask & Answer tab opens the question composer sheet', (tester) async {
    final client = buildClient();

    await tester.pumpWidget(buildTestApp(client));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Ask a question'), findsOneWidget);
  });

  testWidgets('FAB on Showcase tab opens the showcase composer sheet', (tester) async {
    final client = buildClient();

    await tester.pumpWidget(buildTestApp(client));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Showcase'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Share your project'), findsOneWidget);
  });
}
