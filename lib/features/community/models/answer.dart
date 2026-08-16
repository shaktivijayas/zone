class Answer {
  const Answer({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.upvotes,
    required this.authorHash,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final int upvotes;
  final String authorHash;

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      upvotes: json['upvotes'] as int,
      authorHash: json['authorHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'upvotes': upvotes,
      'authorHash': authorHash,
    };
  }
}
