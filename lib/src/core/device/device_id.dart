import 'dart:async';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Generates and persists a device identifier for telemetry/anti-abuse signals.
class DeviceId {
  static const _key = 'sl.device.id.v1';

  /// Returns a stable device id, creating one if necessary.
  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = _generate();
    await prefs.setString(_key, generated);
    return generated;
  }

  static String _generate() {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      final n = random.nextInt(1 << 32);
      buffer.write(n.toRadixString(16).padLeft(8, '0'));
    }
    return buffer.toString();
  }
}
