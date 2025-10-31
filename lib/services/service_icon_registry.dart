import 'package:flutter/widgets.dart';

import '../utils/key_normalizer.dart';
import 'service_icon/service_icon_registry.dart' as internal;
import 'service_icon/service_icon_widget.dart';

/// Compatibility shim that keeps the legacy ServiceIconRegistry API available
/// while delegating implementation to the v2 icon pipeline.
class ServiceIconRegistry {
  const ServiceIconRegistry._();

  static Future<void> init() => internal.ServiceIconRegistry.init();

  static Map<String, String> get icons =>
      internal.ServiceIconRegistry.instance.icons;

  static Widget iconFor(
    String key, {
    double size = 24,
    IconData? fallback,
  }) {
    final normalized = KeyNormalizer.normalize(key);
    return ServiceIcon.forKey(
      normalized,
      size: size,
      fallback: fallback,
    );
  }

  static Widget? iconForOrNull(
    String? key, {
    double size = 24,
    IconData? fallback,
  }) {
    if (key == null || key.isEmpty) {
      return null;
    }
    return iconFor(key, size: size, fallback: fallback);
  }

  static String? pathFor(String key) {
    final normalized = KeyNormalizer.normalize(key);
    return internal.ServiceIconRegistry.pathFor(normalized);
  }

  static void clearCache() {
    internal.ServiceIconRegistry.instance.clear();
  }

  static Map<String, String> debugAutoMap() {
    final map = <String, String>{};
    for (final entry in KeyNormalizer.aliases.entries) {
      map[entry.key] = pathFor(entry.value) ?? '';
    }
    for (final entry in icons.entries) {
      map.putIfAbsent(entry.key, () => pathFor(entry.key) ?? entry.value);
    }
    return map;
  }
}
