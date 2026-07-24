import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zone/core/device/device_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('getOrCreateUuid generates and persists a uuid on first call', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = DeviceService(prefs);

    final first = await service.getOrCreateUuid();
    final second = await service.getOrCreateUuid();

    expect(first, isNotEmpty);
    expect(second, equals(first));
  });

  test('hashUuid produces a deterministic 16-character hash', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = DeviceService(prefs);

    final hash1 = service.hashUuid('11111111-1111-1111-1111-111111111111');
    final hash2 = service.hashUuid('11111111-1111-1111-1111-111111111111');
    final hash3 = service.hashUuid('22222222-2222-2222-2222-222222222222');

    expect(hash1.length, 16);
    expect(hash1, equals('a7428c83b0febe1c'));
    expect(hash1, equals(hash2));
    expect(hash1, isNot(equals(hash3)));
  });

  test('getOrCreateHashedDeviceId returns hash of the persisted uuid', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = DeviceService(prefs);

    final hashedId = await service.getOrCreateHashedDeviceId();
    final uuid = await service.getOrCreateUuid();

    expect(hashedId, equals(service.hashUuid(uuid)));
  });
}
