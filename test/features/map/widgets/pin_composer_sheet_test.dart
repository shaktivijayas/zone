import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zone/core/network/api_client.dart';
import 'package:zone/features/map/widgets/pin_composer_sheet.dart';

void main() {
  Widget buildTestApp(MockClient mockClient) {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWith(
          (ref) async => ApiClient(hashedDeviceId: 'test', httpClient: mockClient, baseUrl: 'http://test.local'),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const PinComposerSheet(),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('submitting valid text posts the right body shape and closes the sheet', (tester) async {
    Map<String, dynamic>? postedBody;
    final mockClient = MockClient((req) async {
      if (req.method == 'POST') {
        postedBody = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'new-pin',
            'text': postedBody!['text'],
            'lat': postedBody!['lat'],
            'lng': postedBody!['lng'],
            'flair': 'Info',
            'createdAt': 1700000000000,
            'expiresAt': 1700001800000,
            'upvotes': 0,
            'authorHash': 'a1b2c3d4',
          }),
          201,
        );
      }
      // GET /pins triggered by the post-create refresh.
      return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Free pizza near the library');
    // Unfocus before submitting: the text field's blinking cursor keeps a
    // periodic timer alive, which would make pumpAndSettle spin forever.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Drop pin'));
    // The geolocator plugin channel has no handler registered in tests, so
    // resolving it (before falling back to campus center) needs a real
    // async gap via runAsync rather than the fake frame clock.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(postedBody, isNotNull);
    expect(postedBody!['text'], 'Free pizza near the library');
    expect(postedBody!.containsKey('lat'), isTrue);
    expect(postedBody!.containsKey('lng'), isTrue);

    // Sheet closes on success.
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('ApiException from a 422 moderation rejection surfaces as visible text and keeps the sheet open', (tester) async {
    final mockClient = MockClient((req) async {
      if (req.method == 'POST') {
        return http.Response(jsonEncode({'error': 'Content violates community guidelines'}), 422);
      }
      return http.Response(jsonEncode(<Map<String, dynamic>>[]), 200);
    });

    await tester.pumpWidget(buildTestApp(mockClient));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'some bad text');
    // Unfocus before submitting: the text field's blinking cursor keeps a
    // periodic timer alive, which would make pumpAndSettle spin forever.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Drop pin'));
    // The geolocator plugin channel has no handler registered in tests, so
    // resolving it (before falling back to campus center) needs a real
    // async gap via runAsync rather than the fake frame clock.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Content violates community guidelines'), findsOneWidget);
    // Sheet stays open.
    expect(find.byType(TextField), findsOneWidget);
  });
}
