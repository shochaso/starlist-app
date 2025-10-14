import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class AssetImageIndex {
  static const _prefixes = <String>[
    'assets/icons/services/',
  ];

  static const _exts = ['.png', '.jpg', '.jpeg', '.webp', '.svg'];

  static Future<Map<String, dynamic>> _loadManifest() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    return json.decode(manifestJson) as Map<String, dynamic>;
  }

  static Future<List<String>> listImages() async {
    final manifest = await _loadManifest();
    final keys = manifest.keys.cast<String>();
    final filtered = keys.where((path) {
      final lower = path.toLowerCase();
      final hasPrefix = _prefixes.any(lower.startsWith);
      final hasExt = _exts.any(lower.endsWith);
      return hasPrefix && hasExt;
    }).toList(growable: false);
    return filtered;
  }
}
