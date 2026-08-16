import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/map/map_screen.dart';

Map<String, dynamic> _pinJson({required String id, required String text}) => {
  'id': id,
  'text': text,
  'lat': 13.0827,
  'lng': 80.2707,
  'flair': 'Hot',
  'createdAt': DateTime.now().millisecondsSinceEpoch,
  'expiresAt': DateTime.now().millisecondsSinceEpoch + 1800000,
  'upvotes': 0,
  'authorHash': 'a1b2c3d4',
};

void main() {
  Widget buildTestApp(MockClient mockClient) {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWith(
          (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
        ),
      ],
      child: const MaterialApp(home: MapScreen()),
    );
  }

  testWidgets('renders fetched pins as list tiles with their text visible', (tester) async {
    final mockClient = MockClient((req) async {
      return http.Response(
        jsonEncode([
          _pinJson(id: 'pin-1', text: 'Free pizza near the library'),
          _pinJson(id: 'pin-2', text: 'Fire alarm test in progress'),
        ]),
        200,
      );
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await tester.pumpAndSettle();

    expect(find.text('Free pizza near the library'), findsOneWidget);
    expect(find.text('Fire alarm test in progress'), findsOneWidget);
  });

  testWidgets('shows empty state text when there are no pins', (tester) async {
    final mockClient = MockClient((req) async {
      return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await tester.pumpAndSettle();

    expect(find.text('No pins yet — be the first to drop one'), findsOneWidget);
  });

  testWidgets('tapping the FAB opens the composer sheet with a text field', (tester) async {
    final mockClient = MockClient((req) async {
      return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
  });
}
