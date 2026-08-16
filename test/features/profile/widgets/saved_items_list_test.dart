import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';
import 'package:zone/features/profile/prefs/saved_items_prefs.dart';
import 'package:zone/features/profile/widgets/saved_items_list.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<SharedPreferences> prefsWithSaved(List<String> ids) async {
    SharedPreferences.setMockInitialValues({savedShowcaseIdsKey: ids});
    return SharedPreferences.getInstance();
  }

  testWidgets('shows empty state when nothing saved', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: Scaffold(body: SavedItemsList())),
      ),
    );

    expect(find.text('No saved items yet'), findsOneWidget);
    expect(find.text('Saved (0)'), findsOneWidget);
  });

  testWidgets('renders a ListTile per saved id with a remove button', (tester) async {
    final prefs = await prefsWithSaved(['showcase-a', 'showcase-b']);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: Scaffold(body: SavedItemsList())),
      ),
    );

    expect(find.text('Saved (2)'), findsOneWidget);
    expect(find.text('showcase-a'), findsOneWidget);
    expect(find.text('showcase-b'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsNWidgets(2));
  });

  testWidgets('tapping remove removes the item from the list', (tester) async {
    final prefs = await prefsWithSaved(['showcase-a']);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: Scaffold(body: SavedItemsList())),
      ),
    );

    expect(find.text('showcase-a'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pumpAndSettle();

    expect(find.text('showcase-a'), findsNothing);
    expect(find.text('No saved items yet'), findsOneWidget);
  });
}
