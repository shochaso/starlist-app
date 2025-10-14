import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:starlist_app/utils/key_normalizer.dart';
import 'package:starlist_app/widgets/icon_diag_hud.dart' show diagTouch;

class ServiceIconRegistry {
  static const _assetBase = 'assets/service_icons/';

  static final Map<String, Map<String, String>> _map = {
    'amazon': {'path': 'amazon.png'},
    'amazon_prime_video': {'path': 'amazon_prime_video.png'},
    'prime_video': {'path': 'amazon_prime_video.png'},
    'netflix': {'path': 'netflix.png'},
    // U-NEXT は HTML renderer との相性問題があるため PNG を強制採用（SVG は保持）
    'u_next': {'path': 'u_next.png'},
    'abema': {'path': 'abema.jpg'},
    'hulu': {'path': 'hulu.jpg'},
    'shein': {'path': 'shein.png'},
    'spotify': {'path': 'spotify.png'},
    'apple_music': {'path': 'apple_music.png'},
    'google_play': {'path': 'google_play.png'},
    'app_store': {'path': 'app_store.png'},
    'nintendo': {'path': 'nintendo.jpg'},
    'playstation': {'path': 'playstation.png'},
    'steam': {'path': 'steam.jpeg'},
    'family_mart': {'path': 'family_mart.jpg'},
    'seven_eleven': {'path': 'seven_eleven.png'},
    'daily_yamazaki': {'path': 'daily_yamazaki.jpeg'},
    'ministop': {'path': 'ministop.jpeg'},
    'uber_eats': {'path': 'uber_eats.jpg'},
    'demaecan': {'path': 'demaecan.jpg'},
    'rakuten': {'path': 'rakuten_ichiba.png'},
    'rakuten_ichiba': {'path': 'rakuten_ichiba.png'},
    'yahoo_shopping': {'path': 'yahoo_shopping.jpg'},
    'zozotown': {'path': 'zozotown.jpg'},
    'gu': {'path': 'gu.jpg'},
    'uniqlo': {'path': 'uniqlo.png'},
    'audible': {'path': 'audible.png'},
    'kindle': {'path': 'kindle.png'},
    'rakuten_books': {'path': 'rakuten_books.png'},
  };

  static Widget iconFor(String rawKey, {double size = 24}) {
    final key = resolveAlias(normalizeKey(rawKey));
    final path = pathFor(key);
    diagTouch(key: key, path: path);
    if (path == null) {
      diagTouch(key: key, fallback: true, incrementCall: false);
      return _fallback(size);
    }

    if (path.startsWith('http')) {
      return _buildNetworkIcon(path, key: key, size: size);
    }

    return _buildAssetIcon(path, key: key, size: size);
  }

  static String? pathFor(String rawKey) {
    final normalizedKey = resolveAlias(normalizeKey(rawKey));
    final path = _map[normalizedKey]?['path'];
    if (path == null || path.isEmpty) {
      return null;
    }
    if (path.startsWith('http')) {
      return path;
    }
    return '$_assetBase$path';
  }

  static Map<String, String> debugAutoMap() {
    return _map.map((key, value) => MapEntry(key, pathFor(key) ?? ''));
  }

  static Widget _fallback(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        color: Colors.black12,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'NO',
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  static Widget _buildNetworkIcon(String path, {required String key, required double size}) {
    final isSvg = path.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return Builder(
        builder: (context) {
          final tint = _resolveTint(path, context);
          return SvgPicture.network(
            path,
            width: size,
            height: size,
            allowDrawingOutsideViewBox: true,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            placeholderBuilder: (_) => SizedBox(width: size, height: size),
          );
        },
      );
    }
    return Image.network(
      path,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) {
        diagTouch(key: key, path: path, fallback: true, incrementCall: false);
        return _fallback(size);
      },
    );
  }

  static Widget _buildAssetIcon(String path, {required String key, required double size}) {
    final isSvg = path.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return Builder(
        builder: (context) {
          final tint = _resolveTint(path, context);
          return SvgPicture.asset(
            path,
            width: size,
            height: size,
            allowDrawingOutsideViewBox: true,
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            placeholderBuilder: (_) => SizedBox(width: size, height: size),
          );
        },
      );
    }
    return _buildAssetImage(path, key: key, size: size);
  }

  static Color _resolveTint(String path, BuildContext context) {
    if (path.contains('unext.svg')) {
      return const Color(0xFF00AEEF);
    }
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  static Widget _buildAssetImage(String path, {required String key, required double size}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) {
        diagTouch(key: key, path: path, fallback: true, incrementCall: false);
        return _fallback(size);
      },
    );
  }

  // NOTE: If the underlying SVG is eventually simplified (viewBox + simple paths only),
  // we can drop allowDrawingOutsideViewBox for a leaner render path.
}
