import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/feed/feed_screen.dart';

void main() {
  final samplePost = {
    'id': 'p1',
    'title': 'Staff near C Block',
    'body': 'Faculty checking IDs.',
    'flair': 'Alert',
    'createdAt': DateTime.now().millisecondsSinceEpoch,
    'upvotes': 42,
    'commentCount': 18,
    'authorHash': 'a1b2c3d4e5f60718',
  };

  Widget buildTestApp({List<Map<String, dynamic>> posts = const []}) {
    final effectivePosts = posts;
    final mockClient = MockClient((req) async {
      if (req.method == 'GET' && req.url.path == '/posts') {
        return http.Response(jsonEncode(effectivePosts), 200);
      }
      if (req.method == 'GET' && req.url.path.endsWith('/comments')) {
        return http.Response(jsonEncode([]), 200);
      }
      return http.Response(jsonEncode({}), 200);
    });
    final client = ApiClient(hashedDeviceId: 'test-hash', httpClient: mockClient, baseUrl: 'http://test.local');

    return ProviderScope(
      overrides: [apiClientProvider.overrideWith((ref) async => client)],
      child: const MaterialApp(home: FeedScreen()),
    );
  }

  testWidgets('renders posts as cards with visible title, body, and flair', (tester) async {
    await tester.pumpWidget(buildTestApp(posts: [samplePost]));
    await tester.pumpAndSettle();

    expect(find.text('Staff near C Block'), findsOneWidget);
    expect(find.text('Faculty checking IDs.'), findsOneWidget);
    expect(find.textContaining('Alert'), findsOneWidget);
  });

  testWidgets('shows empty state when there are no posts', (tester) async {
    await tester.pumpWidget(buildTestApp(posts: const []));
    await tester.pumpAndSettle();

    expect(find.text('No posts yet — share the first update'), findsOneWidget);
  });

  testWidgets('tapping the FAB opens the composer sheet', (tester) async {
    await tester.pumpWidget(buildTestApp(posts: [samplePost]));
    await tester.pumpAndSettle();

    expect(find.text('New Post'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Post'), findsOneWidget);
  });

  testWidgets('tapping a post card opens the comments sheet', (tester) async {
    await tester.pumpWidget(buildTestApp(posts: [samplePost]));
    await tester.pumpAndSettle();

    expect(find.text('Comments'), findsNothing);

    await tester.tap(find.text('Staff near C Block'));
    await tester.pumpAndSettle();

    expect(find.text('Comments'), findsOneWidget);
  });
}
