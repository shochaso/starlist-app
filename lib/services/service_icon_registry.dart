import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';

class ServiceIconRegistry {
  static const _configPath = 'assets/config/service_icons.json';
  static Map<String, String>? _icons;

  static Future<void> init() async {
    if (_icons != null) {
      return;
    }
    final jsonString = await rootBundle.loadString(_configPath);
    final Map<String, dynamic> decoded = json.decode(jsonString) as Map<String, dynamic>;
    _icons = decoded.map(
      (key, value) => MapEntry(key, value as String),
    );
  }

  static Map<String, String> get icons => _icons ?? const {};

  static String? iconPath(String key) => icons[key];

  static Widget iconFor(
    String key, {
    double? size,
    BoxFit fit = BoxFit.contain,
  }) {
    final path = iconPath(key);
    if (path == null) {
      return const SizedBox.shrink();
    }
    final lower = path.toLowerCase();
    if (lower.endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: size,
        height: size,
        fit: fit,
      );
    }
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: fit,
    );
  }
}

class ServiceIconRegistryDebug {
  static Map<String, String> readMap() => Map.unmodifiable(ServiceIconRegistry.icons);
}
