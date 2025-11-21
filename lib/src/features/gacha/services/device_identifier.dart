import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Device identification helper for Lv2-Lite analytics
/// 
/// Provides consistent device identification across the app for
/// ad view tracking and analytics purposes.
class DeviceIdentifier {
  static String? _cachedDeviceId;

  /// Get a device identifier for the current device
  /// 
  /// Returns a consistent identifier that can be used for:
  /// - Ad view tracking and daily limit enforcement
  /// - Device-level analytics (multi-account detection)
  /// - Lv2-Lite observation and abuse pattern detection
  /// 
  /// Note: For production, consider using:
  /// - Android: Android ID or Firebase Installation ID
  /// - iOS: identifierForVendor or Firebase Installation ID
  /// - Web: Generated UUID stored in localStorage
  /// 
  /// This implementation provides a simple fallback that should be
  /// replaced with a proper device ID library in production.
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    String deviceId;

    if (kIsWeb) {
      // For web, we could use a UUID stored in localStorage
      // For now, use a simple identifier
      deviceId = 'web-${_generateSimpleId()}';
    } else {
      try {
        if (Platform.isAndroid) {
          // In production, use: device_info_plus package
          // androidInfo.androidId or Firebase Installation ID
          deviceId = 'android-${_generateSimpleId()}';
        } else if (Platform.isIOS) {
          // In production, use: device_info_plus package
          // iosInfo.identifierForVendor or Firebase Installation ID
          deviceId = 'ios-${_generateSimpleId()}';
        } else {
          deviceId = 'unknown-${_generateSimpleId()}';
        }
      } catch (e) {
        deviceId = 'error-${_generateSimpleId()}';
      }
    }

    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Generate a simple identifier (for testing)
  /// 
  /// In production, this should be replaced with:
  /// - Android: `androidInfo.androidId` from device_info_plus
  /// - iOS: `iosInfo.identifierForVendor` from device_info_plus
  /// - Web: UUID generated and stored in localStorage
  /// - Or: Firebase Installation ID (recommended for all platforms)
  static String _generateSimpleId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    // This is a very basic implementation - use proper device ID in production
    return timestamp.toString().substring(timestamp.toString().length - 8);
  }

  /// Reset cached device ID (for testing)
  static void resetCache() {
    _cachedDeviceId = null;
  }

  /// Production implementation notes:
  /// 
  /// For Android (recommended):
  /// ```dart
  /// import 'package:device_info_plus/device_info_plus.dart';
  /// 
  /// final deviceInfo = DeviceInfoPlugin();
  /// final androidInfo = await deviceInfo.androidInfo;
  /// return androidInfo.androidId; // Unique per app installation
  /// ```
  /// 
  /// For iOS (recommended):
  /// ```dart
  /// import 'package:device_info_plus/device_info_plus.dart';
  /// 
  /// final deviceInfo = DeviceInfoPlugin();
  /// final iosInfo = await deviceInfo.iosInfo;
  /// return iosInfo.identifierForVendor; // Unique per app installation
  /// ```
  /// 
  /// For Web (recommended):
  /// ```dart
  /// import 'package:uuid/uuid.dart';
  /// import 'package:shared_preferences/shared_preferences.dart';
  /// 
  /// final prefs = await SharedPreferences.getInstance();
  /// String? deviceId = prefs.getString('device_id');
  /// if (deviceId == null) {
  ///   deviceId = const Uuid().v4();
  ///   await prefs.setString('device_id', deviceId);
  /// }
  /// return deviceId;
  /// ```
  /// 
  /// Firebase Installation ID (cross-platform):
  /// ```dart
  /// import 'package:firebase_core/firebase_core.dart';
  /// 
  /// final installationId = await FirebaseInstallations.instance.getId();
  /// return installationId;
  /// ```
}
