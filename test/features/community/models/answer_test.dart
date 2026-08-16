import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/community/models/answer.dart';

void main() {
  group('Answer', () {
    test('fromJson parses all fields', () {
      final answer = Answer.fromJson({
        'id': 'a1',
        'text': 'Check the clubs page in the app.',
        'createdAt': 1700000000000,
        'upvotes': 3,
        'authorHash': 'hash456',
      });

      expect(answer.id, 'a1');
      expect(answer.text, 'Check the clubs page in the app.');
      expect(answer.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(answer.upvotes, 3);
      expect(answer.authorHash, 'hash456');
    });

    test('toJson round-trips', () {
      final answer = Answer(
        id: 'a1',
        text: 'hi',
        createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
        upvotes: 0,
        authorHash: 'hash456',
      );

      expect(Answer.fromJson(answer.toJson()).text, 'hi');
      expect(answer.toJson()['createdAt'], 2000);
    });
  });
}
