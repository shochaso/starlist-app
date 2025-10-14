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
