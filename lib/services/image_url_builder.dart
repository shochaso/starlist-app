import '../config/debug_flags.dart';
import '../config/environment_config.dart';

class ImageUrlBuilder {
  const ImageUrlBuilder._();

  static String thumbnail(
    String originUrl, {
    int width = 480,
  }) {
    if (originUrl.isEmpty) {
      return originUrl;
    }
    final normalized = _normalizeOrigin(originUrl);
    final params = 'width=$width,format=auto,quality=85,fit=cover';
    final url =
        '${EnvironmentConfig.assetsCdnOrigin}/cdn-cgi/image/$params/$normalized';
    if (DebugFlags.instance.imageDiagnostics) {
      // ignore: avoid_print
      print('[ImageUrlBuilder] thumbnail=$url');
    }
    return url;
  }

  static String original(String originUrl) {
    if (originUrl.isEmpty) {
      return originUrl;
    }
    final normalized = _normalizeOrigin(originUrl);
    final url = '${EnvironmentConfig.assetsCdnOrigin}/$normalized';
    if (DebugFlags.instance.imageDiagnostics) {
      // ignore: avoid_print
      print('[ImageUrlBuilder] original=$url');
    }
    return url;
  }

  static String _normalizeOrigin(String originUrl) {
    if (originUrl.contains('/cdn-cgi/image/')) {
      return _stripLeadingSlash(_stripBase(originUrl));
    }
    final sanitized = _stripBase(originUrl);
    return _stripLeadingSlash(sanitized);
  }

  static String _stripBase(String originUrl) {
    const cdn = EnvironmentConfig.assetsCdnOrigin;
    if (originUrl.startsWith(cdn)) {
      return originUrl.substring(cdn.length);
    }
    final uri = Uri.tryParse(originUrl);
    if (uri != null && uri.hasScheme) {
      final path = uri.hasAuthority
          ? uri.path
          : originUrl;
      final combined = uri.hasQuery ? '$path?${uri.query}' : path;
      return combined;
    }
    return originUrl;
  }

  static String _stripLeadingSlash(String value) {
    if (value.startsWith('//')) {
      return value.replaceFirst('//', '');
    }
    if (value.startsWith('/')) {
      return value.substring(1);
    }
    return value;
  }
}
