class ShowcaseProject {
  const ShowcaseProject({
    required this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.imageUrl,
    required this.createdAt,
    required this.bookmarkCount,
    required this.authorHash,
  });

  final String id;
  final String title;
  final String description;
  final List<String> techStack;
  final String? imageUrl;
  final DateTime createdAt;
  final int bookmarkCount;
  final String authorHash;

  factory ShowcaseProject.fromJson(Map<String, dynamic> json) {
    final rawTechStack = json['techStack'] as List?;
    return ShowcaseProject(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      techStack: rawTechStack == null ? const [] : rawTechStack.map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      bookmarkCount: json['bookmarkCount'] as int,
      authorHash: json['authorHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'techStack': techStack,
      'imageUrl': imageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'bookmarkCount': bookmarkCount,
      'authorHash': authorHash,
    };
  }
}
