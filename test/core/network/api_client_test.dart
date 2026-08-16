import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';

void main() {
  group('ApiClient', () {
    test('get sends the X-Device-Hash header and decodes JSON', () async {
      late http.BaseRequest captured;
      final mockClient = MockClient((req) async {
        captured = req;
        return http.Response(jsonEncode({'ok': true}), 200);
      });
      final client = ApiClient(
        hashedDeviceId: 'a1b2c3d4e5f60718',
        httpClient: mockClient,
        baseUrl: 'http://test.local',
      );

      final result = await client.get('/pins');

      expect(captured.headers['X-Device-Hash'], 'a1b2c3d4e5f60718');
      expect(captured.url.toString(), 'http://test.local/pins');
      expect(result, {'ok': true});
    });

    test('post sends a JSON body and returns decoded response', () async {
      final mockClient = MockClient((req) async {
        expect(req.method, 'POST');
        expect(jsonDecode(req.body), {'text': 'hi'});
        return http.Response(jsonEncode({'id': '1'}), 201);
      });
      final client = ApiClient(hashedDeviceId: 'a1b2c3d4e5f60718', httpClient: mockClient, baseUrl: 'http://test.local');

      final result = await client.post('/pins', {'text': 'hi'});

      expect(result, {'id': '1'});
    });

    test('throws ApiException with the server-provided message on non-2xx', () async {
      final mockClient = MockClient((req) async {
        return http.Response(jsonEncode({'error': 'content rejected'}), 422);
      });
      final client = ApiClient(hashedDeviceId: 'a1b2c3d4e5f60718', httpClient: mockClient, baseUrl: 'http://test.local');

      expect(
        () => client.post('/pins', {'text': 'bad'}),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 422).having((e) => e.message, 'message', 'content rejected')),
      );
    });
  });
}
