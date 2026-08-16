import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/feed/providers/feed_provider.dart';

void main() {
  final samplePost = {
    'id': 'p1',
    'title': 'Staff near C Block',
    'body': 'Faculty checking IDs.',
    'flair': 'Alert',
    'createdAt': 1755350400000,
    'upvotes': 42,
    'commentCount': 18,
    'authorHash': 'a1b2c3d4e5f60718',
  };

  final sampleComment = {
    'id': 'c1',
    'text': 'Thanks for the heads up!',
    'createdAt': 1755350460000,
    'authorHash': 'b2c3d4e5f6071829',
  };

  ProviderContainer buildContainer(
    Future<http.Response> Function(http.Request) handler,
  ) {
    final mockClient = MockClient((req) async => handler(req as http.Request));
    final client = ApiClient(hashedDeviceId: 'test-hash', httpClient: mockClient, baseUrl: 'http://test.local');
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWith((ref) async => client)],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('postsProvider', () {
    test('fetches and parses the post list from GET /posts', () async {
      final container = buildContainer((req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/posts');
        return http.Response(jsonEncode([samplePost]), 200);
      });

      final posts = await container.read(postsProvider.future);

      expect(posts, hasLength(1));
      expect(posts.first.id, 'p1');
      expect(posts.first.title, 'Staff near C Block');
    });

    test('createPost posts the right shape and refreshes the list', () async {
      var postCount = 0;
      var getCount = 0;
      final container = buildContainer((req) async {
        if (req.method == 'POST') {
          postCount++;
          expect(req.url.path, '/posts');
          expect(jsonDecode(req.body), {'title': 'New title', 'body': 'New body'});
          return http.Response(jsonEncode({...samplePost, 'id': 'p2'}), 201);
        }
        getCount++;
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(postsProvider.future);
      await container.read(postsProvider.notifier).createPost(title: 'New title', body: 'New body');

      expect(postCount, 1);
      expect(getCount, 2); // initial build + refresh after create
    });

    test('createPost includes flair when provided', () async {
      final container = buildContainer((req) async {
        if (req.method == 'POST') {
          expect(jsonDecode(req.body), {'title': 't', 'body': 'b', 'flair': 'Hot'});
          return http.Response(jsonEncode(samplePost), 201);
        }
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(postsProvider.future);
      await container.read(postsProvider.notifier).createPost(title: 't', body: 'b', flair: 'Hot');
    });

    test('createPost propagates ApiException on 422 moderation rejection', () async {
      final container = buildContainer((req) async {
        if (req.method == 'POST') {
          return http.Response(jsonEncode({'error': 'flagged content'}), 422);
        }
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(postsProvider.future);

      expect(
        () => container.read(postsProvider.notifier).createPost(title: 't', body: 'b'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422)),
      );
    });

    test('upvote calls PATCH /posts/:id/upvote and refreshes', () async {
      var patchCalled = false;
      final container = buildContainer((req) async {
        if (req.method == 'PATCH') {
          patchCalled = true;
          expect(req.url.path, '/posts/p1/upvote');
          return http.Response(jsonEncode({'id': 'p1', 'upvotes': 43}), 200);
        }
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(postsProvider.future);
      await container.read(postsProvider.notifier).upvote('p1');

      expect(patchCalled, isTrue);
    });

    test('upvote propagates ApiException on 404', () async {
      final container = buildContainer((req) async {
        if (req.method == 'PATCH') {
          return http.Response(jsonEncode({'error': 'not found'}), 404);
        }
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(postsProvider.future);

      expect(
        () => container.read(postsProvider.notifier).upvote('missing'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });
  });

  group('commentsProvider', () {
    test('fetches comments for a given postId', () async {
      final container = buildContainer((req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/posts/p1/comments');
        return http.Response(jsonEncode([sampleComment]), 200);
      });

      final comments = await container.read(commentsProvider('p1').future);

      expect(comments, hasLength(1));
      expect(comments.first.text, 'Thanks for the heads up!');
    });

    test('addComment posts and refreshes comments and post list', () async {
      var commentPostCount = 0;
      var postsGetCount = 0;
      var commentsGetCount = 0;
      final container = buildContainer((req) async {
        if (req.method == 'POST' && req.url.path == '/posts/p1/comments') {
          commentPostCount++;
          expect(jsonDecode(req.body), {'text': 'hello'});
          return http.Response(jsonEncode({...sampleComment, 'id': 'c2'}), 201);
        }
        if (req.url.path == '/posts/p1/comments') {
          commentsGetCount++;
          return http.Response(jsonEncode([sampleComment]), 200);
        }
        postsGetCount++;
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(postsProvider.future);
      await container.read(commentsProvider('p1').future);
      await container.read(commentsProvider('p1').notifier).addComment('hello');

      expect(commentPostCount, 1);
      expect(commentsGetCount, 2); // initial + refresh after add
      expect(postsGetCount, 2); // initial + refresh after add (commentCount bump)
    });

    test('addComment propagates ApiException on 422 moderation rejection', () async {
      final container = buildContainer((req) async {
        if (req.method == 'POST') {
          return http.Response(jsonEncode({'error': 'flagged content'}), 422);
        }
        if (req.url.path == '/posts/p1/comments') {
          return http.Response(jsonEncode([sampleComment]), 200);
        }
        return http.Response(jsonEncode([samplePost]), 200);
      });

      await container.read(commentsProvider('p1').future);

      expect(
        () => container.read(commentsProvider('p1').notifier).addComment('bad'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422)),
      );
    });
  });
}
