import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/features/profile/prefs/saved_items_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getSavedIds defaults to empty set', () async {
    final prefs = await SharedPreferences.getInstance();
    final savedItemsPrefs = SavedItemsPrefs(prefs);

    expect(savedItemsPrefs.getSavedIds(), isEmpty);
  });

  test('toggleSaved adds an id when not present', () async {
    final prefs = await SharedPreferences.getInstance();
    final savedItemsPrefs = SavedItemsPrefs(prefs);

    await savedItemsPrefs.toggleSaved('showcase-1');

    expect(savedItemsPrefs.getSavedIds(), {'showcase-1'});
    expect(savedItemsPrefs.isSaved('showcase-1'), isTrue);
  });

  test('toggleSaved removes an id when already present', () async {
    final prefs = await SharedPreferences.getInstance();
    final savedItemsPrefs = SavedItemsPrefs(prefs);

    await savedItemsPrefs.toggleSaved('showcase-1');
    await savedItemsPrefs.toggleSaved('showcase-1');

    expect(savedItemsPrefs.getSavedIds(), isEmpty);
    expect(savedItemsPrefs.isSaved('showcase-1'), isFalse);
  });

  test('isSaved returns false for an id never saved', () async {
    final prefs = await SharedPreferences.getInstance();
    final savedItemsPrefs = SavedItemsPrefs(prefs);

    expect(savedItemsPrefs.isSaved('missing'), isFalse);
  });

  test('round-trips multiple ids across instances backed by the same prefs', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = SavedItemsPrefs(prefs);
    await first.toggleSaved('a');
    await first.toggleSaved('b');

    final second = SavedItemsPrefs(prefs);
    expect(second.getSavedIds(), {'a', 'b'});
  });
}
