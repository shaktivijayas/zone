import 'package:flutter_test/flutter_test.dart';
import 'package:zone/features/map/models/pin.dart';

void main() {
  group('Pin', () {
    final json = {
      'id': 'pin-1',
      'text': 'Free pizza in the quad',
      'lat': 13.0827,
      'lng': 80.2707,
      'flair': 'Hot',
      'createdAt': 1700000000000,
      'expiresAt': 1700001800000,
      'upvotes': 3,
      'authorHash': 'a1b2c3d4',
    };

    test('fromJson parses all fields correctly', () {
      final pin = Pin.fromJson(json);

      expect(pin.id, 'pin-1');
      expect(pin.text, 'Free pizza in the quad');
      expect(pin.lat, 13.0827);
      expect(pin.lng, 80.2707);
      expect(pin.flair, 'Hot');
      expect(pin.createdAt, 1700000000000);
      expect(pin.expiresAt, 1700001800000);
      expect(pin.upvotes, 3);
      expect(pin.authorHash, 'a1b2c3d4');
    });

    test('createdAtTime and expiresAtTime derive from the ms epoch values', () {
      final pin = Pin.fromJson(json);

      expect(pin.createdAtTime, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(pin.expiresAtTime, DateTime.fromMillisecondsSinceEpoch(1700001800000));
    });

    test('fromJson handles integer lat/lng (server may send whole numbers)', () {
      final intJson = Map<String, dynamic>.from(json)
        ..['lat'] = 13
        ..['lng'] = 80;

      final pin = Pin.fromJson(intJson);

      expect(pin.lat, 13.0);
      expect(pin.lng, 80.0);
    });

    test('toJson produces a creation payload with text/lat/lng/flair', () {
      final pin = Pin.fromJson(json);

      final payload = pin.toJson();

      expect(payload['text'], 'Free pizza in the quad');
      expect(payload['lat'], 13.0827);
      expect(payload['lng'], 80.2707);
      expect(payload['flair'], 'Hot');
    });
  });
}
