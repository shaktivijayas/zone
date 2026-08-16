import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/device/device_service.dart';
import '../../../core/network/api_client.dart';

/// Karma is computed client-side: sum of `upvotes` across pins, posts, and
/// community questions authored by this anonymous device. There is no
/// dedicated backend endpoint for this — it's a deliberate scoping
/// simplification per the Profile module spec.
final karmaProvider = FutureProvider<int>((ref) async {
  final myHash = await ref.watch(hashedDeviceIdProvider.future);
  final client = await ref.watch(apiClientProvider.future);

  final results = await Future.wait([
    client.get('/pins'),
    client.get('/posts'),
    client.get('/community/questions'),
  ]);

  int sumUpvotesFor(dynamic list) {
    if (list is! List) return 0;
    var total = 0;
    for (final item in list) {
      if (item is Map && item['authorHash'] == myHash) {
        final upvotes = item['upvotes'];
        if (upvotes is int) {
          total += upvotes;
        } else if (upvotes is num) {
          total += upvotes.toInt();
        }
      }
    }
    return total;
  }

  return results.map(sumUpvotesFor).fold<int>(0, (a, b) => a + b);
});
