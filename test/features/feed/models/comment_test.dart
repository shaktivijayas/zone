import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/feed/models/comment.dart';

void main() {
  group('Comment', () {
    final json = {
      'id': 'c1',
      'text': 'Thanks for the heads up!',
      'createdAt': 1755350460000,
      'authorHash': 'b2c3d4e5f6071829',
    };

    test('fromJson parses all fields correctly', () {
      final comment = Comment.fromJson(json);

      expect(comment.id, 'c1');
      expect(comment.text, 'Thanks for the heads up!');
      expect(comment.createdAt, 1755350460000);
      expect(comment.authorHash, 'b2c3d4e5f6071829');
    });

    test('createdAtTime converts epoch-ms to DateTime', () {
      final comment = Comment.fromJson(json);

      expect(comment.createdAtTime, DateTime.fromMillisecondsSinceEpoch(1755350460000));
    });
  });
}
