import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/community/models/showcase_project.dart';

void main() {
  group('ShowcaseProject', () {
    test('fromJson parses all fields', () {
      final project = ShowcaseProject.fromJson({
        'id': 's1',
        'title': 'Campus Dashboard',
        'description': 'A tool for tracking events.',
        'techStack': ['Flutter', 'Firebase'],
        'imageUrl': 'https://example.com/image.png',
        'createdAt': 1700000000000,
        'bookmarkCount': 4,
        'authorHash': 'hash789',
      });

      expect(project.id, 's1');
      expect(project.title, 'Campus Dashboard');
      expect(project.description, 'A tool for tracking events.');
      expect(project.techStack, ['Flutter', 'Firebase']);
      expect(project.imageUrl, 'https://example.com/image.png');
      expect(project.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(project.bookmarkCount, 4);
      expect(project.authorHash, 'hash789');
    });

    test('fromJson defaults techStack to empty list when omitted', () {
      final project = ShowcaseProject.fromJson({
        'id': 's1',
        'title': 'T',
        'description': 'D',
        'createdAt': 1000,
        'bookmarkCount': 0,
        'authorHash': 'hash789',
        'imageUrl': null,
      });

      expect(project.techStack, isEmpty);
      expect(project.imageUrl, isNull);
    });

    test('toJson round-trips', () {
      final project = ShowcaseProject(
        id: 's1',
        title: 'T',
        description: 'D',
        techStack: const ['Flutter'],
        imageUrl: null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(3000),
        bookmarkCount: 1,
        authorHash: 'hash789',
      );

      expect(ShowcaseProject.fromJson(project.toJson()).techStack, ['Flutter']);
      expect(project.toJson()['createdAt'], 3000);
    });
  });
}
