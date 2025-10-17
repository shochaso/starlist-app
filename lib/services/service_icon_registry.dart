import 'package:flutter/widgets.dart';

import 'package:starlist_app/config/ui_flags.dart';
import 'package:starlist_app/utils/key_normalizer.dart';
import 'package:starlist_app/widgets/icon_diag_hud.dart' show diagTouch;

class ServiceIconRegistry {
  static const Map<String, Map<String, String>> _map = {};

  static Map<String, String> get icons => const {};

  static Future<void> init() async {}

  static Widget iconFor(String rawKey, {double size = 24}) {
    final key = resolveAlias(normalizeKey(rawKey));
    diagTouch(key: key, path: '');
    return SizedBox(width: size, height: size);
  }

  static String? pathFor(String rawKey) {
    resolveAlias(normalizeKey(rawKey));
    return kHideImportImages ? '' : '';
  }

  static Map<String, String> debugAutoMap() {
    return _map.map((key, _) => MapEntry(key, ''));
  }

  static Widget? iconForOrNull(String rawKey, {double size = 24}) {
    if (kHideImportImages) {
      return SizedBox(width: size, height: size);
    }
    return null;
  }
}
