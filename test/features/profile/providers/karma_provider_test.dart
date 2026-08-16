import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/profile/providers/karma_provider.dart';

const _myHash = 'me1234567890abcd';
const _otherHash = 'other9876543210x';

void main() {
  ProviderContainer buildContainer(http.Client mockClient) {
    return ProviderContainer(
      overrides: [
        hashedDeviceIdProvider.overrideWith((ref) async => _myHash),
        apiClientProvider.overrideWith(
          (ref) async => ApiClient(hashedDeviceId: _myHash, httpClient: mockClient, baseUrl: 'http://test.local'),
        ),
      ],
    );
  }

  test('sums upvotes across pins, posts, and questions authored by this device', () async {
    final mockClient = MockClient((req) async {
      if (req.url.path == '/pins') {
        return http.Response(
          jsonEncode([
            {'id': 'p1', 'authorHash': _myHash, 'upvotes': 3},
            {'id': 'p2', 'authorHash': _otherHash, 'upvotes': 100},
          ]),
          200,
        );
      } else if (req.url.path == '/posts') {
        return http.Response(
          jsonEncode([
            {'id': 'post1', 'authorHash': _myHash, 'upvotes': 5},
            {'id': 'post2', 'authorHash': _otherHash, 'upvotes': 7},
          ]),
          200,
        );
      } else if (req.url.path == '/community/questions') {
        return http.Response(
          jsonEncode([
            {'id': 'q1', 'authorHash': _myHash, 'upvotes': 2},
          ]),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    final container = buildContainer(mockClient);
    addTearDown(container.dispose);

    final karma = await container.read(karmaProvider.future);

    expect(karma, 3 + 5 + 2);
  });

  test('excludes items authored by other devices entirely', () async {
    final mockClient = MockClient((req) async {
      return http.Response(
        jsonEncode([
          {'id': 'x1', 'authorHash': _otherHash, 'upvotes': 42},
        ]),
        200,
      );
    });

    final container = buildContainer(mockClient);
    addTearDown(container.dispose);

    final karma = await container.read(karmaProvider.future);

    expect(karma, 0);
  });

  test('returns 0 when all lists are empty', () async {
    final mockClient = MockClient((req) async {
      return http.Response(jsonEncode([]), 200);
    });

    final container = buildContainer(mockClient);
    addTearDown(container.dispose);

    final karma = await container.read(karmaProvider.future);

    expect(karma, 0);
  });

  test('propagates ApiException when a fetch fails', () async {
    final mockClient = MockClient((req) async {
      return http.Response(jsonEncode({'error': 'server exploded'}), 500);
    });

    final container = buildContainer(mockClient);
    addTearDown(container.dispose);

    // Note: awaiting karmaProvider.future directly hangs when the provider
    // rejects (observed with flutter_riverpod 3.3.2 outside a widget test
    // pump loop), so we observe the error via a listener instead.
    final completer = Completer<Object>();
    container.listen(karmaProvider, (_, next) {
      if (next.hasError && !completer.isCompleted) {
        completer.complete(next.error);
      }
    }, fireImmediately: true);

    final error = await completer.future;
    expect(error, isA<ApiException>());
  });
}
