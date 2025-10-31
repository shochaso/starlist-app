import 'dart:collection';

/// Provides normalization and alias resolution for service keys used across the
/// application. The goal is to turn loosely formatted user input (mixed case,
/// hyphen variations, Japanese full-width characters, etc.) into a canonical
/// identifier that matches CDN asset naming.
class KeyNormalizer {
  KeyNormalizer._();

  /// Normalizes [raw] into a canonical key and then resolves known aliases.
  static String normalize(String raw) {
    if (raw.isEmpty) {
      return raw;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final halfWidth = _toHalfWidth(trimmed);
    final lower = halfWidth.toLowerCase();

    final directAlias = _aliasMap[lower];
    if (directAlias != null) {
      return directAlias;
    }

    final flattened = lower.replaceAll(RegExp(r'[\s-]+'), '_');
    final flattenedAlias = _aliasMap[flattened];
    if (flattenedAlias != null) {
      return flattenedAlias;
    }

    final normalized = _canonicalize(halfWidth);
    return resolveAlias(normalized);
  }

  /// Resolves a previously normalized key to its canonical alias target.
  static String resolveAlias(String key) => _aliasMap[key] ?? key;

  /// Exposes a read-only view of all registered aliases.
  static Map<String, String> get aliases =>
      UnmodifiableMapView<String, String>(_aliasMap);

  static String _canonicalize(String raw) {
    final buffer = StringBuffer();
    var value = raw.trim();
    if (value.isEmpty) {
      return '';
    }

    value = _toHalfWidth(value);
    value = value.toLowerCase();
    value = value.replaceAll(RegExp(r'[　]+'), ' '); // full-width spaces
    value = value.replaceAll(RegExp(r'[&＋]+'), ' and ');
    value = value.replaceAll(RegExp(r'[‐‑‒–—―〜〜~]+'), '-');
    value = value.replaceAll(RegExp(r'[・·•]+'), '_');

    var lastWasSeparator = false;
    for (final codePoint in value.runes) {
      final char = String.fromCharCode(codePoint);
      if (_isAsciiLetterOrDigit(codePoint)) {
        buffer.write(char);
        lastWasSeparator = false;
      } else if (char == '_') {
        if (!lastWasSeparator) {
          buffer.write('_');
          lastWasSeparator = true;
        }
      } else if (char == '-') {
        if (!lastWasSeparator) {
          buffer.write('_');
          lastWasSeparator = true;
        }
      } else if (char == ' ') {
        if (!lastWasSeparator) {
          buffer.write('_');
          lastWasSeparator = true;
        }
      } else {
        lastWasSeparator = true;
      }
    }

    var result = buffer.toString();
    result = result.replaceAll(RegExp(r'_+'), '_');
    result = result.replaceAll(RegExp(r'^_+|_+$'), '');
    return result;
  }

  static bool _isAsciiLetterOrDigit(int codePoint) {
    const int zero = 0x30;
    const int nine = 0x39;
    const int a = 0x61;
    const int z = 0x7A;
    return (codePoint >= zero && codePoint <= nine) ||
        (codePoint >= a && codePoint <= z);
  }

  static String _toHalfWidth(String value) {
    final buffer = StringBuffer();
    for (final codePoint in value.runes) {
      if (codePoint >= 0xFF01 && codePoint <= 0xFF5E) {
        buffer.writeCharCode(codePoint - 0xFEE0);
      } else {
        buffer.writeCharCode(codePoint);
      }
    }
    return buffer.toString();
  }

  static const Map<String, String> _aliasMap = {
    'amazon_prime': 'prime_video',
    'amazon_prime_video': 'prime_video',
    'amazon_primevideo': 'prime_video',
    'amazonprime': 'prime_video',
    'amazonprimevideo': 'prime_video',
    'primevideo': 'prime_video',
    'prime_video': 'prime_video',
    'prime-video': 'prime_video',
    'amazon_prime_music': 'amazon_music',
    'amazonmusic': 'amazon_music',
    'applemusic': 'apple_music',
    'googleplay': 'google_play',
    'google_play_store': 'google_play',
    'net-flix': 'netflix',
    'u-next': 'unext',
    'unext': 'unext',
    'u_next': 'unext',
    'u_next_japan': 'unext',
    'u_next_video': 'unext',
    'u-next-video': 'unext',
    'ユーネクスト': 'unext',
    'ユーネク': 'unext',
    'u next': 'unext',
    'youtubecom': 'youtube',
    'youtube_japan': 'youtube',
    'yt': 'youtube',
    'uber_eats': 'uber_eats',
    'ubereats': 'uber_eats',
    'uber-eats': 'uber_eats',
    'uber_eats_jp': 'uber_eats',
    'ウーバーイーツ': 'uber_eats',
    'spotify_jp': 'spotify',
    'spotifyjp': 'spotify',
    'appstore': 'app_store',
    'shein_fashion': 'shein',
    'sheinjp': 'shein',
    'she_in': 'shein',
    'she-in': 'shein',
    'shein_jp': 'shein',
    'シーイン': 'shein',
    'seven-eleven': 'seven_eleven',
    '7_eleven': 'seven_eleven',
    '7eleven': 'seven_eleven',
    'demae_can': 'demaecan',
    'simpleicons': 'generic',
    'familymart': 'familymart',
    'family_mart': 'familymart',
    'lawson': 'lawson',
    'daily_yamazaki': 'daily_yamazaki',
    'ministop': 'ministop',
    'mini_stop': 'ministop',
    'seven': 'seven_eleven',
    'seveneleven': 'seven_eleven',
    'seven_eleven_store': 'seven_eleven',
  };
}

String normalizeKey(String raw) => KeyNormalizer.normalize(raw);

String resolveAlias(String key) => KeyNormalizer.resolveAlias(key);
