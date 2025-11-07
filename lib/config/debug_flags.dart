/// Reads debug toggles from the current URL (`?debugIcons=true`) or via
/// `--dart-define`. These flags let developers enable diagnostic overlays
/// without touching source code.
library;

const bool _envDebugIcons =
    bool.fromEnvironment('DEBUG_ICONS', defaultValue: false);
const bool _envDebugImages =
    bool.fromEnvironment('DEBUG_IMAGES', defaultValue: false);

class DebugFlags {
  DebugFlags._();

  static final DebugFlags instance = DebugFlags._();

  bool get iconDiagnostics => _resolve('debugIcons', _envDebugIcons);
  bool get imageDiagnostics => _resolve('debugImages', _envDebugImages);

  bool _resolve(String queryParam, bool envValue) {
    final queryValue = Uri.base.queryParameters[queryParam];
    if (queryValue != null) {
      return _parseBool(queryValue);
    }
    return envValue;
  }

  bool _parseBool(String value) {
    switch (value.toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
      case 'on':
        return true;
      default:
        return false;
    }
  }
}
