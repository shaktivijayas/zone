class Comment {
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.authorHash,
  });

  final String id;
  final String text;
  final int createdAt;
  final String authorHash;

  DateTime get createdAtTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
      authorHash: json['authorHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'createdAt': createdAt, 'authorHash': authorHash};
  }
}
