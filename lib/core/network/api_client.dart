import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../device/device_service.dart';

/// Base URL for the ZONE backend. Override at build time with
/// --dart-define=ZONE_API_BASE_URL=https://your-deployed-backend for release builds.
const String _defaultBaseUrl = String.fromEnvironment(
  'ZONE_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:4000',
);

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({required this.hashedDeviceId, http.Client? httpClient, String? baseUrl})
    : _client = httpClient ?? http.Client(),
      baseUrl = baseUrl ?? _defaultBaseUrl;

  final String hashedDeviceId;
  final String baseUrl;
  final http.Client _client;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Device-Hash': hashedDeviceId,
  };

  Future<dynamic> get(String path) async {
    final res = await _client.get(Uri.parse('$baseUrl$path'), headers: _headers);
    return _decode(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> patch(String path, [Map<String, dynamic> body = const {}]) async {
    final res = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final decoded = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }
    final message = decoded is Map && decoded['error'] != null
        ? decoded['error'].toString()
        : 'request failed';
    throw ApiException(res.statusCode, message);
  }
}

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final hashedDeviceId = await ref.watch(hashedDeviceIdProvider.future);
  return ApiClient(hashedDeviceId: hashedDeviceId);
});
