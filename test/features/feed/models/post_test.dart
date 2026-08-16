import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/feed/models/post.dart';

void main() {
  group('Post', () {
    final json = {
      'id': 'p1',
      'title': 'Staff near C Block',
      'body': 'Faculty checking IDs.',
      'flair': 'Alert',
      'createdAt': 1755350400000,
      'upvotes': 42,
      'commentCount': 18,
      'authorHash': 'a1b2c3d4e5f60718',
    };

    test('fromJson parses all fields correctly', () {
      final post = Post.fromJson(json);

      expect(post.id, 'p1');
      expect(post.title, 'Staff near C Block');
      expect(post.body, 'Faculty checking IDs.');
      expect(post.flair, 'Alert');
      expect(post.createdAt, 1755350400000);
      expect(post.upvotes, 42);
      expect(post.commentCount, 18);
      expect(post.authorHash, 'a1b2c3d4e5f60718');
    });

    test('createdAtTime converts epoch-ms to DateTime', () {
      final post = Post.fromJson(json);

      expect(post.createdAtTime, DateTime.fromMillisecondsSinceEpoch(1755350400000));
    });

    test('toJson round-trips through fromJson', () {
      final post = Post.fromJson(json);
      final roundTripped = Post.fromJson(post.toJson());

      expect(roundTripped.id, post.id);
      expect(roundTripped.title, post.title);
      expect(roundTripped.upvotes, post.upvotes);
    });
  });
}
