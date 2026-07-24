import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _deviceUuidKey = 'zone_device_uuid';
const _hashSalt = 'zone_salt_2024';

class DeviceService {
  DeviceService(this._prefs);

  final SharedPreferences _prefs;

  Future<String> getOrCreateUuid() async {
    final existing = _prefs.getString(_deviceUuidKey);
    if (existing != null) return existing;
    final generated = const Uuid().v4();
    await _prefs.setString(_deviceUuidKey, generated);
    return generated;
  }

  String hashUuid(String uuid) {
    final bytes = utf8.encode(uuid + _hashSalt);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  Future<String> getOrCreateHashedDeviceId() async {
    final uuid = await getOrCreateUuid();
    return hashUuid(uuid);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('overridden in main.dart via ProviderScope overrides');
});

final deviceServiceProvider = Provider<DeviceService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DeviceService(prefs);
});

final hashedDeviceIdProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(deviceServiceProvider);
  return service.getOrCreateHashedDeviceId();
});
