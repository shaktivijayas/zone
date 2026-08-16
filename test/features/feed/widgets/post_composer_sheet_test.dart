import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/feed/widgets/post_composer_sheet.dart';

void main() {
  Widget buildTestApp(Future<http.Response> Function(http.Request) handler) {
    final mockClient = MockClient((req) async => handler(req));
    final client = ApiClient(hashedDeviceId: 'test-hash', httpClient: mockClient, baseUrl: 'http://test.local');

    return ProviderScope(
      overrides: [apiClientProvider.overrideWith((ref) async => client)],
      child: const MaterialApp(
        home: Scaffold(body: PostComposerSheet()),
      ),
    );
  }

  testWidgets('submitting valid title+body calls create with the right shape', (tester) async {
    Map<String, dynamic>? capturedBody;
    String? capturedPath;

    await tester.pumpWidget(
      buildTestApp((req) async {
        if (req.method == 'POST') {
          capturedPath = req.url.path;
          capturedBody = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'id': 'p1',
              'title': 'Hello',
              'body': 'World',
              'flair': 'Info',
              'createdAt': DateTime.now().millisecondsSinceEpoch,
              'upvotes': 0,
              'commentCount': 0,
              'authorHash': 'hash',
            }),
            201,
          );
        }
        return http.Response(jsonEncode([]), 200);
      }),
    );

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Hello');
    await tester.enterText(find.widgetWithText(TextField, "What's happening?"), 'World');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Post'));
    await tester.pumpAndSettle();

    expect(capturedPath, '/posts');
    expect(capturedBody, {'title': 'Hello', 'body': 'World'});
  });

  testWidgets('a 422 ApiException shows visibly in the widget tree', (tester) async {
    await tester.pumpWidget(
      buildTestApp((req) async {
        if (req.method == 'POST') {
          return http.Response(jsonEncode({'error': 'flagged as inappropriate'}), 422);
        }
        return http.Response(jsonEncode([]), 200);
      }),
    );

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Bad title');
    await tester.enterText(find.widgetWithText(TextField, "What's happening?"), 'Bad body');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Post'));
    await tester.pumpAndSettle();

    expect(find.text('flagged as inappropriate'), findsOneWidget);
    // Sheet stays open (its content is still in the tree) on failure.
    expect(find.text('New Post'), findsOneWidget);
  });
}
