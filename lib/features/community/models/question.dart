class Question {
  const Question({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.upvotes,
    required this.answerCount,
    required this.acceptedAnswerId,
    required this.authorHash,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final int upvotes;
  final int answerCount;
  final String? acceptedAnswerId;
  final String authorHash;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      upvotes: json['upvotes'] as int,
      answerCount: json['answerCount'] as int,
      acceptedAnswerId: json['acceptedAnswerId'] as String?,
      authorHash: json['authorHash'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'upvotes': upvotes,
      'answerCount': answerCount,
      'acceptedAnswerId': acceptedAnswerId,
      'authorHash': authorHash,
    };
  }
}
