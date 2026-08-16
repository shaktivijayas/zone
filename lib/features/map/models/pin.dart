/// A single campus map pin: a decaying, location-tagged post.
///
/// Decay (base 30min life, +5min per upvote, capped at 2h from creation) is
/// entirely server-managed — this client only displays [expiresAt] and
/// re-fetches periodically; it never computes the countdown itself.
class Pin {
  const Pin({
    required this.id,
    required this.text,
    required this.lat,
    required this.lng,
    required this.flair,
    required this.createdAt,
    required this.expiresAt,
    required this.upvotes,
    required this.authorHash,
  });

  factory Pin.fromJson(Map<String, dynamic> json) => Pin(
    id: json['id'] as String,
    text: json['text'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    flair: json['flair'] as String,
    createdAt: json['createdAt'] as int,
    expiresAt: json['expiresAt'] as int,
    upvotes: json['upvotes'] as int,
    authorHash: json['authorHash'] as String,
  );

  final String id;
  final String text;
  final double lat;
  final double lng;
  final String flair;
  final int createdAt;
  final int expiresAt;
  final int upvotes;
  final String authorHash;

  /// Epoch-ms [createdAt] as a [DateTime].
  DateTime get createdAtTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

  /// Epoch-ms [expiresAt] as a [DateTime].
  DateTime get expiresAtTime => DateTime.fromMillisecondsSinceEpoch(expiresAt);

  /// Payload shape for `POST /pins` — server assigns id/createdAt/expiresAt/upvotes.
  Map<String, dynamic> toJson() => {
    'text': text,
    'lat': lat,
    'lng': lng,
    'flair': flair,
  };
}
