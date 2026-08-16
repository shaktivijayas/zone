import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/community/providers/community_provider.dart';

Map<String, dynamic> _questionJson({
  String id = 'q1',
  String title = 'T',
  String body = 'B',
  int upvotes = 0,
  int answerCount = 0,
  String? acceptedAnswerId,
  String authorHash = 'author-hash',
}) {
  return {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': 1000,
    'upvotes': upvotes,
    'answerCount': answerCount,
    'acceptedAnswerId': acceptedAnswerId,
    'authorHash': authorHash,
  };
}

Map<String, dynamic> _answerJson({String id = 'a1', String text = 'text', int upvotes = 0}) {
  return {'id': id, 'text': text, 'createdAt': 1000, 'upvotes': upvotes, 'authorHash': 'answerer-hash'};
}

Map<String, dynamic> _showcaseJson({
  String id = 's1',
  String title = 'Proj',
  int bookmarkCount = 0,
  List<String> techStack = const [],
}) {
  return {
    'id': id,
    'title': title,
    'description': 'desc',
    'techStack': techStack,
    'imageUrl': null,
    'createdAt': 1000,
    'bookmarkCount': bookmarkCount,
    'authorHash': 'author-hash',
  };
}

ProviderContainer _buildContainer(ApiClient client) {
  final container = ProviderContainer(
    overrides: [apiClientProvider.overrideWith((ref) async => client)],
  );
  return container;
}

void main() {
  group('questionsProvider', () {
    test('fetches questions from GET /community/questions', () async {
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          expect(req.method, 'GET');
          expect(req.url.path, '/community/questions');
          return http.Response(jsonEncode([_questionJson(id: 'q1', title: 'Hello')]), 200);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final questions = await container.read(questionsProvider.future);

      expect(questions, hasLength(1));
      expect(questions.first.title, 'Hello');
    });
  });

  group('answersProvider', () {
    test('fetches answers for a given question id', () async {
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          expect(req.method, 'GET');
          expect(req.url.path, '/community/questions/q1/answers');
          return http.Response(jsonEncode([_answerJson(text: 'Try this')]), 200);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final answers = await container.read(answersProvider('q1').future);

      expect(answers, hasLength(1));
      expect(answers.first.text, 'Try this');
    });
  });

  group('showcaseProvider', () {
    test('fetches showcase projects from GET /community/showcase', () async {
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          expect(req.method, 'GET');
          expect(req.url.path, '/community/showcase');
          return http.Response(jsonEncode([_showcaseJson(title: 'Cool App')]), 200);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final projects = await container.read(showcaseProvider.future);

      expect(projects, hasLength(1));
      expect(projects.first.title, 'Cool App');
    });
  });

  group('CommunityActions.createQuestion', () {
    test('POSTs the right body and refreshes questionsProvider', () async {
      var getCount = 0;
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          if (req.method == 'GET') {
            getCount++;
            final list = getCount == 1 ? <Map<String, dynamic>>[] : [_questionJson(id: 'q1', title: 'New Q')];
            return http.Response(jsonEncode(list), 200);
          }
          expect(req.method, 'POST');
          expect(req.url.path, '/community/questions');
          expect(jsonDecode(req.body), {'title': 'New Q', 'body': 'Body text'});
          return http.Response(jsonEncode(_questionJson(id: 'q1', title: 'New Q')), 201);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final before = await container.read(questionsProvider.future);
      expect(before, isEmpty);

      await container.read(communityActionsProvider).createQuestion(title: 'New Q', body: 'Body text');

      final after = await container.read(questionsProvider.future);
      expect(after, hasLength(1));
      expect(getCount, 2);
    });

    test('propagates ApiException on moderation rejection', () async {
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          return http.Response(jsonEncode({'error': 'rejected', 'reason': 'spam'}), 422);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      expect(
        () => container.read(communityActionsProvider).createQuestion(title: 'x', body: 'y'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422)),
      );
    });
  });

  group('CommunityActions.addAnswer', () {
    test('POSTs the answer and refreshes both answersProvider and questionsProvider', () async {
      var questionsGetCount = 0;
      var answersGetCount = 0;
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          if (req.method == 'GET' && req.url.path == '/community/questions') {
            questionsGetCount++;
            final answerCount = questionsGetCount == 1 ? 0 : 1;
            return http.Response(jsonEncode([_questionJson(id: 'q1', answerCount: answerCount)]), 200);
          }
          if (req.method == 'GET' && req.url.path == '/community/questions/q1/answers') {
            answersGetCount++;
            final list = answersGetCount == 1 ? <Map<String, dynamic>>[] : [_answerJson(id: 'a1', text: 'An answer')];
            return http.Response(jsonEncode(list), 200);
          }
          expect(req.method, 'POST');
          expect(req.url.path, '/community/questions/q1/answers');
          expect(jsonDecode(req.body), {'text': 'An answer'});
          return http.Response(jsonEncode(_answerJson(id: 'a1', text: 'An answer')), 201);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final beforeQuestions = await container.read(questionsProvider.future);
      final beforeAnswers = await container.read(answersProvider('q1').future);
      expect(beforeQuestions.first.answerCount, 0);
      expect(beforeAnswers, isEmpty);

      await container.read(communityActionsProvider).addAnswer(questionId: 'q1', text: 'An answer');

      final afterQuestions = await container.read(questionsProvider.future);
      final afterAnswers = await container.read(answersProvider('q1').future);
      expect(afterQuestions.first.answerCount, 1);
      expect(afterAnswers, hasLength(1));
    });
  });

  group('CommunityActions.acceptAnswer', () {
    test('PATCHes accept endpoint and refreshes questionsProvider', () async {
      var getCount = 0;
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          if (req.method == 'GET') {
            getCount++;
            final acceptedId = getCount == 1 ? null : 'a1';
            return http.Response(jsonEncode([_questionJson(id: 'q1', acceptedAnswerId: acceptedId)]), 200);
          }
          expect(req.method, 'PATCH');
          expect(req.url.path, '/community/questions/q1/accept/a1');
          return http.Response(jsonEncode({'id': 'q1', 'acceptedAnswerId': 'a1'}), 200);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final before = await container.read(questionsProvider.future);
      expect(before.first.acceptedAnswerId, isNull);

      await container.read(communityActionsProvider).acceptAnswer(questionId: 'q1', answerId: 'a1');

      final after = await container.read(questionsProvider.future);
      expect(after.first.acceptedAnswerId, 'a1');
    });

    test('propagates 403 ApiException when caller is not the question author', () async {
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          return http.Response(jsonEncode({'error': 'only the question author can accept an answer'}), 403);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      expect(
        () => container.read(communityActionsProvider).acceptAnswer(questionId: 'q1', answerId: 'a1'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403)),
      );
    });
  });

  group('CommunityActions.createShowcaseProject', () {
    test('POSTs the right body and refreshes showcaseProvider', () async {
      var getCount = 0;
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          if (req.method == 'GET') {
            getCount++;
            final list = getCount == 1 ? <Map<String, dynamic>>[] : [_showcaseJson(id: 's1', title: 'New Project')];
            return http.Response(jsonEncode(list), 200);
          }
          expect(req.method, 'POST');
          expect(req.url.path, '/community/showcase');
          expect(
            jsonDecode(req.body),
            {'title': 'New Project', 'description': 'Desc', 'techStack': ['Flutter']},
          );
          return http.Response(jsonEncode(_showcaseJson(id: 's1', title: 'New Project')), 201);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final before = await container.read(showcaseProvider.future);
      expect(before, isEmpty);

      await container.read(communityActionsProvider).createShowcaseProject(
        title: 'New Project',
        description: 'Desc',
        techStack: const ['Flutter'],
      );

      final after = await container.read(showcaseProvider.future);
      expect(after, hasLength(1));
      expect(getCount, 2);
    });
  });

  group('CommunityActions.bookmarkProject', () {
    test('PATCHes bookmark endpoint and refreshes showcaseProvider', () async {
      var getCount = 0;
      final client = ApiClient(
        hashedDeviceId: 'device1',
        baseUrl: 'http://test.local',
        httpClient: MockClient((req) async {
          if (req.method == 'GET') {
            getCount++;
            final count = getCount == 1 ? 0 : 1;
            return http.Response(jsonEncode([_showcaseJson(id: 's1', bookmarkCount: count)]), 200);
          }
          expect(req.method, 'PATCH');
          expect(req.url.path, '/community/showcase/s1/bookmark');
          return http.Response(jsonEncode({'id': 's1', 'bookmarkCount': 1}), 200);
        }),
      );
      final container = _buildContainer(client);
      addTearDown(container.dispose);

      final before = await container.read(showcaseProvider.future);
      expect(before.first.bookmarkCount, 0);

      await container.read(communityActionsProvider).bookmarkProject('s1');

      final after = await container.read(showcaseProvider.future);
      expect(after.first.bookmarkCount, 1);
    });
  });
}
