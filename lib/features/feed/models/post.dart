class Post {
  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.flair,
    required this.createdAt,
    required this.upvotes,
    required this.commentCount,
    required this.authorHash,
  });

  final String id;
  final String title;
  final String body;
  final String flair;
  final int createdAt;
  final int upvotes;
  final int commentCount;
  final String authorHash;

  DateTime get createdAtTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      flair: json['flair'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      upvotes: (json['upvotes'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      authorHash: json['authorHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'flair': flair,
      'createdAt': createdAt,
      'upvotes': upvotes,
      'commentCount': commentCount,
      'authorHash': authorHash,
    };
  }
}
