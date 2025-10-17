import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

bool _sheinChecked = false;

Future<void> debugCheckShein() async {
  if (!kDebugMode || _sheinChecked) {
    return;
  }
  _sheinChecked = true;
  const path = 'assets/service_icons/shein.png';
  try {
    final data = await rootBundle.load(path);
    debugPrint('[SHEIN] bytes=${data.lengthInBytes}');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    debugPrint('[SHEIN] decoded ${frame.image.width}x${frame.image.height}');
  } catch (error, stackTrace) {
    debugPrint('[SHEIN] ERROR loading: $error');
    debugPrint('$stackTrace');
  }
}
