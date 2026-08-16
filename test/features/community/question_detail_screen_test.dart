import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/community/models/question.dart';
import 'package:zone/features/community/question_detail_screen.dart';

void main() {
  Question buildQuestion({required String authorHash, String? acceptedAnswerId}) {
    return Question(
      id: 'q1',
      title: 'How do I join clubs?',
      body: 'New here, need pointers.',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      upvotes: 0,
      answerCount: 1,
      acceptedAnswerId: acceptedAnswerId,
      authorHash: authorHash,
    );
  }

  ApiClient buildClient() {
    return ApiClient(
      hashedDeviceId: 'me',
      baseUrl: 'http://test.local',
      httpClient: MockClient((req) async {
        if (req.method == 'GET' && req.url.path == '/community/questions/q1/answers') {
          return http.Response(
            jsonEncode([
              {'id': 'a1', 'text': 'Try the clubs page', 'createdAt': 1000, 'upvotes': 1, 'authorHash': 'h2'},
            ]),
            200,
          );
        }
        if (req.method == 'GET' && req.url.path == '/community/questions') {
          return http.Response(jsonEncode([]), 200);
        }
        return http.Response('{}', 200);
      }),
    );
  }

  Widget buildTestApp({required ApiClient client, required String deviceHash, required Question question}) {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWith((ref) async => client),
        hashedDeviceIdProvider.overrideWith((ref) async => deviceHash),
      ],
      child: MaterialApp(home: QuestionDetailScreen(question: question)),
    );
  }

  testWidgets('renders answers and shows Accept button when current device is the question author', (tester) async {
    final client = buildClient();
    await tester.pumpWidget(
      buildTestApp(client: client, deviceHash: 'me', question: buildQuestion(authorHash: 'me')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Try the clubs page'), findsOneWidget);
    expect(find.text('Accept'), findsOneWidget);
  });

  testWidgets('hides Accept button when current device is not the question author', (tester) async {
    final client = buildClient();
    await tester.pumpWidget(
      buildTestApp(client: client, deviceHash: 'someone-else', question: buildQuestion(authorHash: 'me')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Try the clubs page'), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
  });

  testWidgets('hides Accept button when the question already has an accepted answer', (tester) async {
    final client = buildClient();
    await tester.pumpWidget(
      buildTestApp(
        client: client,
        deviceHash: 'me',
        question: buildQuestion(authorHash: 'me', acceptedAnswerId: 'a1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accept'), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });
}
