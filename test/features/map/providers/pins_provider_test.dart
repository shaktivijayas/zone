import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/map/models/pin.dart';
import 'package:zone/features/map/providers/pins_provider.dart';

Map<String, dynamic> _pinJson({
  String id = 'pin-1',
  String text = 'Free pizza',
  int upvotes = 0,
}) => {
  'id': id,
  'text': text,
  'lat': 13.0827,
  'lng': 80.2707,
  'flair': 'Hot',
  'createdAt': 1700000000000,
  'expiresAt': 1700001800000,
  'upvotes': upvotes,
  'authorHash': 'a1b2c3d4',
};

void main() {
  group('pinsProvider', () {
    test('fetches and parses the pin list', () async {
      final mockClient = MockClient((req) async {
        expect(req.method, 'GET');
        expect(req.url.path, '/pins');
        return http.Response(
          jsonEncode([_pinJson(id: 'pin-1'), _pinJson(id: 'pin-2')]),
          200,
        );
      });
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith(
            (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final pins = await container.read(pinsProvider.future);

      expect(pins, hasLength(2));
      expect(pins[0].id, 'pin-1');
      expect(pins[1].id, 'pin-2');
    });

    test('createPin posts the right body and refreshes the list', () async {
      var getCount = 0;
      Map<String, dynamic>? postedBody;
      final mockClient = MockClient((req) async {
        if (req.method == 'GET') {
          getCount++;
          return http.Response(jsonEncode([_pinJson()]), 200);
        }
        if (req.method == 'POST') {
          postedBody = jsonDecode(req.body) as Map<String, dynamic>;
          expect(req.url.path, '/pins');
          return http.Response(jsonEncode(_pinJson(id: 'new-pin')), 201);
        }
        throw StateError('unexpected request');
      });
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith(
            (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pinsProvider.future);
      expect(getCount, 1);

      final created = await container.read(pinsProvider.notifier).createPin(
        text: 'New pin text',
        lat: 13.0,
        lng: 80.0,
      );

      expect(created.id, 'new-pin');
      expect(postedBody, {'text': 'New pin text', 'lat': 13.0, 'lng': 80.0});
      // refresh triggers another GET
      expect(getCount, 2);
    });

    test('createPin includes flair when provided', () async {
      Map<String, dynamic>? postedBody;
      final mockClient = MockClient((req) async {
        if (req.method == 'GET') {
          return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
        }
        postedBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(jsonEncode(_pinJson()), 201);
      });
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith(
            (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pinsProvider.notifier).createPin(
        text: 'Alert text',
        lat: 13.0,
        lng: 80.0,
        flair: 'Alert',
      );

      expect(postedBody!['flair'], 'Alert');
    });

    test('createPin propagates ApiException instead of swallowing it', () async {
      final mockClient = MockClient((req) async {
        if (req.method == 'GET') {
          return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
        }
        return http.Response(jsonEncode({'error': 'content rejected'}), 422);
      });
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith(
            (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pinsProvider.future);

      expect(
        () => container.read(pinsProvider.notifier).createPin(text: 'bad', lat: 1, lng: 1),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'content rejected')),
      );
    });

    test('upvote patches the right endpoint and refreshes the list', () async {
      var getCount = 0;
      String? patchedPath;
      final mockClient = MockClient((req) async {
        if (req.method == 'GET') {
          getCount++;
          return http.Response(jsonEncode([_pinJson(id: 'pin-1', upvotes: getCount == 1 ? 0 : 1)]), 200);
        }
        if (req.method == 'PATCH') {
          patchedPath = req.url.path;
          return http.Response(jsonEncode({'id': 'pin-1', 'upvotes': 1, 'expiresAt': 1700001900000}), 200);
        }
        throw StateError('unexpected request');
      });
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWith(
            (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(pinsProvider.future);
      expect(getCount, 1);

      await container.read(pinsProvider.notifier).upvote('pin-1');

      expect(patchedPath, '/pins/pin-1/upvote');
      expect(getCount, 2);
      final pins = container.read(pinsProvider).value!;
      expect(pins.single.upvotes, 1);
    });
  });
}
