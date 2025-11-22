// DEPRECATED: Legacy ad bridge for web-based ad system.
// New implementation: lib/src/features/gacha/services/ad_service.dart
// Uses server-side RPC complete_ad_view_and_grant_ticket() for ad tracking.
@Deprecated('Use lib/src/features/gacha/services/ad_service.dart instead')
import 'dart:async';
import 'dart:js' as js;

class AdBridge {
  static Future<bool> showRewarded() async {
    final completer = Completer<bool>();
    try {
      js.context.callMethod('starlistShowRewarded', [
        (bool success) => completer.complete(success),
      ]);
    } catch (_) {
      completer.complete(false);
    }
    return completer.future;
  }
}
