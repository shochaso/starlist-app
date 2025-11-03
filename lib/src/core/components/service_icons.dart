import 'package:flutter/material.dart';

import 'package:starlist_app/services/service_icon_registry.dart';
import 'package:starlist_app/services/service_icon/service_icon_widget.dart';
import 'package:starlist_app/src/core/constants/service_definitions.dart';
import 'package:starlist_app/utils/key_normalizer.dart';

/// Shim for legacy `ServiceIcons.*` helpers. Delegates icon rendering to the
/// v2 pipeline while keeping gradients/cards compatible with existing callers.
class ServiceIcons {
  ServiceIcons._();

  /// Get ServiceDefinition (returns name, color, etc.)
  static ServiceDefinition? getService(String key) {
    final normalized = KeyNormalizer.normalize(key);
    return ServiceDefinitions.get(normalized);
  }

  static Gradient getServiceGradient(String key) {
    final normalized = KeyNormalizer.normalize(key);
    final service = ServiceDefinitions.get(normalized);
    if (service != null) {
      return service.gradient;
    }
    final base = _colorFor(normalized);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        base.withOpacity(0.18),
        base.withOpacity(0.36),
      ],
    );
  }

  /// Build icon widget
  static Widget buildIcon({
    required String serviceId,
    double size = 24,
    IconData? fallback,
    bool isDark = false,
  }) {
    // レシートアイコンは1.25倍のサイズで表示
    final normalized = KeyNormalizer.normalize(serviceId);
    final effectiveSize = normalized == 'receipt' ? size * 1.25 : size;
    
    final definition = getService(serviceId);
    final svgPath = definition?.svgPath;
    if (svgPath != null && svgPath.isNotEmpty) {
      return ServiceIcon.asset(
        svgPath,
        size: effectiveSize,
        fallback: fallback,
      );
    }
    return ServiceIconRegistry.iconFor(
      serviceId,
      size: effectiveSize,
      fallback: fallback,
    );
  }

  static Widget buildServiceCard({
    required String serviceId,
    required String title,
    String? subtitle,
    double iconSize = 28,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    bool isConnected = false,
  }) {
    final gradient = getServiceGradient(serviceId);
    final icon = buildIcon(serviceId: serviceId, size: iconSize);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient.colors.isNotEmpty ? gradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (isConnected)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorFor(String key) {
    switch (key) {
      case 'youtube':
        return const Color(0xFFE62117);
      case 'netflix':
        return const Color(0xFFE50914);
      case 'prime_video':
        return const Color(0xFF00A8E1);
      case 'unext':
        return const Color(0xFF1F8FFF);
      case 'shein':
        return const Color(0xFF222222);
      case 'uber_eats':
        return const Color(0xFF06C167);
      default:
        final hash = key.hashCode;
        final hue = (hash % 360).toDouble();
        return HSVColor.fromAHSV(1, hue, 0.36, 0.72).toColor();
    }
  }
}
