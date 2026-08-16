import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/community/models/question.dart';

void main() {
  group('Question', () {
    test('fromJson parses all fields', () {
      final question = Question.fromJson({
        'id': 'q1',
        'title': 'How do I join clubs?',
        'body': 'New here, need pointers.',
        'createdAt': 1700000000000,
        'upvotes': 5,
        'answerCount': 2,
        'acceptedAnswerId': 'a1',
        'authorHash': 'hash123',
      });

      expect(question.id, 'q1');
      expect(question.title, 'How do I join clubs?');
      expect(question.body, 'New here, need pointers.');
      expect(question.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(question.upvotes, 5);
      expect(question.answerCount, 2);
      expect(question.acceptedAnswerId, 'a1');
      expect(question.authorHash, 'hash123');
    });

    test('fromJson handles null acceptedAnswerId', () {
      final question = Question.fromJson({
        'id': 'q1',
        'title': 'T',
        'body': 'B',
        'createdAt': 1000,
        'upvotes': 0,
        'answerCount': 0,
        'acceptedAnswerId': null,
        'authorHash': 'hash123',
      });

      expect(question.acceptedAnswerId, isNull);
    });

    test('toJson round-trips', () {
      final question = Question(
        id: 'q1',
        title: 'T',
        body: 'B',
        createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
        upvotes: 1,
        answerCount: 1,
        acceptedAnswerId: 'a1',
        authorHash: 'hash123',
      );

      expect(Question.fromJson(question.toJson()).id, 'q1');
      expect(question.toJson()['createdAt'], 1000);
    });
  });
}
