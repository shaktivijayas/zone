import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/pin.dart';

/// Holds the current list of active map pins and exposes mutation methods
/// (create/upvote) that refresh the list from the server afterwards.
///
/// Pin decay (base life, +5min per upvote, cap) is entirely server-managed —
/// this notifier just re-fetches `/pins` after any mutation so [expiresAt]
/// values stay current.
class PinsNotifier extends AsyncNotifier<List<Pin>> {
  @override
  Future<List<Pin>> build() => _fetch();

  Future<List<Pin>> _fetch() async {
    final client = await ref.watch(apiClientProvider.future);
    final data = await client.get('/pins');
    return (data as List)
        .map((e) => Pin.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Re-fetches the pin list from the server. Used for pull-to-refresh and
  /// automatically after create/upvote so the UI reflects server state.
  Future<void> refresh() async {
    state = const AsyncLoading<List<Pin>>();
    state = await AsyncValue.guard(_fetch);
  }

  /// Creates a new pin. Throws [ApiException] on failure (e.g. 422 AI
  /// moderation rejection, 400 missing fields) — callers must handle it,
  /// it is never swallowed here.
  Future<Pin> createPin({
    required String text,
    required double lat,
    required double lng,
    String? flair,
  }) async {
    final client = await ref.read(apiClientProvider.future);
    final body = <String, dynamic>{'text': text, 'lat': lat, 'lng': lng};
    if (flair != null) body['flair'] = flair;
    final data = await client.post('/pins', body);
    final pin = Pin.fromJson(data as Map<String, dynamic>);
    await refresh();
    return pin;
  }

  /// Upvotes a pin by id, then refreshes the list so the new upvote count
  /// and extended expiry are reflected.
  Future<void> upvote(String id) async {
    final client = await ref.read(apiClientProvider.future);
    await client.patch('/pins/$id/upvote');
    await refresh();
  }
}

final pinsProvider = AsyncNotifierProvider<PinsNotifier, List<Pin>>(PinsNotifier.new);
